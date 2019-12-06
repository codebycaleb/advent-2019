defmodule Expected do
  def values,
    do: %{
      "01" => %{
        "12" => {2, 0},
        "14" => {2, 2},
        "1969" => {654, 966},
        "100756" => {33583, 50346}
      },
      "02" => %{
        # no good example input / output
        File.read!("assets/inputs/02.txt") => {4_462_686, 5936}
      },
      "03" => %{
        "R75,D30,R83,U83,L12,D49,R71,U7,L72\nU62,R66,U55,R34,D71,R55,D58,R83" => {159, 610}
      }
    }
end
