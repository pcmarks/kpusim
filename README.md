# Kpusim

A very simple simulator of the KPU architecture. It operates by sending signals
and data to several processes under the control of clock.

Typical Usage:
  Kpusim.init(250, 6, 2, 4, fn x -> x * x end)

  Run the simulation with a step time of 250 milliseconds for 6 steps. Use an
  initial value of 2 and a pipeline of 4 PEs. Have each PE compute the square
  of the data token. No debugging text is displayed (the default).
