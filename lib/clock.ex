defmodule Clock do
  require Logger

  @doc """
  Every time the Clock process receives a {:step, m} message it examines
  every component in the simulation to see if the step count indicates that a
  clock signal can be sent to that component.
  """
  def loop(components) do
    receive do
      {:step, step_count} ->
        Logger.debug("Clock step #{step_count}")
        Enum.each(components, fn {_id, {component, clock_count}} ->
          # Check to see if the component can receive a clock signal based on
          # the clock count.
          if rem(step_count, clock_count) == 0, do: send component, {:clkin, step_count}
        end)
        loop(components)
    end
  end
end
