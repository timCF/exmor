defmodule Exmor do
  use Application
  use Silverb,  [
                  {"@escape_reg", [~r/(\\*")/ , ~r/(\\+)$/]},
                  {"@escape_sym", "\\"}
                ]
  use Tinca, [:__exmor__]
  use Hashex, [Exmor.Parsed]
  use Logex, [ttl: 100]

  defmodule Parsed do
    defstruct ok: [],
              error: [],
              info: "" 
  end

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Tinca.declare_namespaces
    notice("use pymor release '#{get_pymor_release}'")
    get_pred

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Exmor.Worker, [arg1, arg2, arg3])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exmor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp get_pymor_release do
    case Tinca.get(:pymor_release) do
      bin when is_binary(bin) -> bin
      nil ->  notice("trying to recognize your OS ... ")
              case :application.get_env(:exmor, :os, nil) do
                bin when (bin in ["linux","mac"]) -> Tinca.put(bin, :pymor_release)
                nil -> get_pymor_release_proc
              end
    end
  end
  defp get_pymor_release_proc do
    raw_str = :os.cmd('uname -s') |> to_string |> String.strip |> String.upcase
    case Enum.filter([~r/DARWIN/, ~r/LINUX/, ~r/CYGWIN/], &(Regex.match?(&1, raw_str))) do
      [~r/DARWIN/] -> Tinca.put("#{:code.priv_dir(:exmor)}/pymor/release/mac/pymor", :pymor_release)
      [~r/LINUX/] -> Tinca.put("#{:code.priv_dir(:exmor)}/pymor/release/linux/pymor", :pymor_release)
      [~r/CYGWIN/] -> raise "#{__MODULE__} : windows is not supported yet"
      #
      # TODO : for windows
      #
      some -> raise "#{__MODULE__} : can't recognize your OS , got #{inspect some}"
    end
  end

  defp get_pred do
    case Tinca.get(:pred) do
      func when is_function(func,1) -> func
      nil ->  case :application.get_env(:exmor, :pred, nil) do
                nil -> Tinca.put(fn(_) -> true end, :pred)
                func when is_function(func,1) -> Tinca.put(func, :pred)
              end
    end
  end

  #
  # public
  #

  def eval(bin) when is_binary(bin), do: eval([bin])
  def eval([]), do: %Exmor.Parsed{}
  def eval(lst = [_|_]) do
    case Enum.all?(lst, &is_binary/1) do
      false -> %Exmor.Parsed{error: lst, info: "#{__MODULE__} : only binaries are supported"}
      true -> 
        pred = get_pred
        case  Enum.map(lst, &(String.split(&1," "))) 
              |> List.flatten 
              |> Stream.filter(&(&1 != "")) 
              |> Stream.uniq
              |> Enum.group_by(pred) do
          %{true: todo, false: denied} -> eval_proc(todo, %Exmor.Parsed{error: denied, info: "#{__MODULE__} denied some binaries"})
          %{true: todo} -> eval_proc(todo, %Exmor.Parsed{})
          %{false: denied} -> %Exmor.Parsed{error: denied, info: "#{__MODULE__} : denied some binaries"}
          %{} -> %Exmor.Parsed{}
        end
    end
  end

  defp eval_proc(todo, res = %Exmor.Parsed{}) do
    case '#{get_pymor_release} #{Stream.map(todo, &("\"#{escape(&1)}\"")) |> Enum.join(" ")}' |> :os.cmd |> to_string |> Jazz.decode do
      {:ok, lst = [_|_]} -> 
        case Enum.all?(lst, &is_binary/1) do
          true -> HashUtils.set(res, :ok, lst)
          false -> HashUtils.modify(res, :error, &(&1++lst)) |> HashUtils.set(:info, "#{__MODULE__} unexpected result from pymor")
        end
      error ->
        HashUtils.modify(res, :error, &([error|&1])) |> HashUtils.set(:info, "#{__MODULE__} unexpected result from pymor")
    end
  end
  
  defp escape(bin), do: Enum.reduce(@escape_reg, bin, fn(reg, acc) -> Exutils.Reg.escape(acc, reg, @escape_sym) end)

end
