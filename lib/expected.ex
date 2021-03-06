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
      },
      "04" => %{
        "99-111" => {2, 1}
      },
      "05" => %{
        # no good example input / output
        File.read!("assets/inputs/05.txt") => {7_566_643, 9_265_694}
      },
      "06" => %{
        # provided
        "COM)B\nB)C\nC)D\nD)E\nE)F\nB)G\nG)H\nD)I\nE)J\nJ)K\nK)L\nK)YOU\nI)SAN" => {54, 4},
        # odd distance
        "COM)A\nA)B\nA)YOU\nB)SAN" => {8, 1},
        # YOU close to COM
        "COM)A\nA)B\nB)C\nC)D\nD)E\nE)F\nA)YOU\nF)SAN" => {30, 5},
        # SAN close to COM
        "COM)A\nA)B\nB)C\nC)D\nD)E\nE)F\nF)YOU\nA)SAN" => {30, 5}
      },
      # "09" => %{
      #   "1102,34915192,34915192,7,4,7,99,0" => {1_219_070_632_396_864, 1_219_070_632_396_864},
      #   "104,1125899906842624,99" => {1_125_899_906_842_624, 1_125_899_906_842_624}
      # },
      "10" => %{
        ".#..##.###...#######\n##.############..##.\n.#.######.########.#\n.###.#######.####.#.\n#####.##.#.##.###.##\n..#####..#.#########\n####################\n#.####....###.#.#.##\n##.#################\n#####.##.###..####..\n..######..##.#######\n####.##.####...##..#\n.#####..#.######.###\n##...#.##########...\n#.##########.#######\n.####.#.###.###.#.##\n....##.##.###..#####\n.#.#.###########.###\n#.#.#.#####.####.###\n###.##.####.##.#..##" =>
          {210, 802}
      },
      "12" => %{
        "<x=-1, y=0, z=2>\n<x=2, y=-10, z=-7>\n<x=4, y=-8, z=8>\n<x=3, y=5, z=-1>" => {183, 2772},
        "<x=-8, y=-10, z=0>\n<x=5, y=5, z=10>\n<x=2, y=-7, z=3>\n<x=9, y=-8, z=-3>" =>
          {14645, 4_686_774_924}
      },
      "16" => %{
        "80871224585914546619083218645595" => {24_176_176, 0},
        "19617804207202209144916044189917" => {73_745_418, 0},
        "69317163492948606335995924319873" => {52_432_133, 0}
      }
    }
end
