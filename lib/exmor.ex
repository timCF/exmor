defmodule Exmor do
  use Application
  use Silverb
  use Tinca, [:__exmor__]

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    Tinca.declare_namespaces
    IO.puts "#{__MODULE__} : set OS param to '#{get_os}'"
    children = [
      # Define workers and child supervisors to be supervised
      # worker(Exmor.Worker, [arg1, arg2, arg3])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Exmor.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp get_os do
    case Tinca.get(:this_os) do
      bin when is_binary(bin) -> bin
      nil ->  IO.puts "#{__MODULE__} : trying to recognize your OS ... "
              case :application.get_env(:exmor, :os, nil) do
                bin when (bin in ["linux","mac"]) -> Tinca.put(bin, :this_os)
                nil -> get_os_proc
              end
    end
  end
  defp get_os_proc do
    raw_str = :os.cmd('uname -s') |> to_string |> String.strip |> String.upcase
    case Enum.filter([~r/DARWIN/, ~r/LINUX/, ~r/CYGWIN/], &(Regex.match?(&1, raw_str))) do
      [~r/DARWIN/] -> Tinca.put("mac", :this_os)
      [~r/LINUX/] -> Tinca.put("linux", :this_os)
      [~r/CYGWIN/] -> raise "#{__MODULE__} : windows is not supported yet"
      #
      # TODO : for windows
      #
      some -> raise "#{__MODULE__} : can't recognize your OS , got #{inspect some}"
    end
  end

end
