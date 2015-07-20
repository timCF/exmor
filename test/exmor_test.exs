defmodule ExmorTest do
  use ExUnit.Case

  test "eval is safe" do
  	%Exmor.Parsed{error: [], info: "", ok: lst} = Exmor.eval("\\\" привет \\\"")
    assert ["\"", "привет", "привета", "приветам", "приветами", "приветах", "привете", "приветов", "приветом", "привету", "приветы"] == Enum.sort(lst)
  	%Exmor.Parsed{error: [], info: "", ok: lst} = Exmor.eval("привет \\")
  	assert ["\\", "привет", "привета", "приветам", "приветами", "приветах", "привете", "приветов", "приветом", "привету", "приветы"] == Enum.sort(lst)
  end

end
