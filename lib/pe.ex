defmodule PE do
  require Logger
  @doc """
  Initialize this PE with an id and a function to execute when required. Enter
  the process loop waiting for messages (signals and data)
  """
  def init(id, fun) do
    loop(id, fun, nil, nil, nil)
  end

  @doc """
  The PE process loop waits for messages (signals and data):
    1. clock signal - triggers a calculation if data is present and sending
       of the result to PE attached to the right (for a pipeline configuration)
    2. data token - a data token has arrived - save it in our state
    3. left/right configuration - when the fabric is being wired together this
       message indicates the left and right PEs in a pipeline.
  """
  def loop(id, fun, data, right, left) do
    receive do
      {:clkin, count} when data != nil ->
        Logger.debug("PE[#{id}].clkin.#{count} - with data: #{data}")
        # calculate and send the result to the next PE
        send right, {:data, fun.(data)}
        loop(id, fun, nil, right, left)
      {:clkin, count} ->
        Logger.debug("PE[#{id}].clkin.#{count} - no data")
        loop(id, fun, data, right, left)
      ## Data has arrived, save and wait for a clock signal
      {:data, data} ->
        Logger.debug("PE[#{id}].data: #{data}")
        loop(id, fun, data, right, left)
      ## Wiring message
      {:left, left, :right, right} ->
        loop(id, fun, data, right, left)
    end
  end
end
