/*[Pegs]*/
peg_diameter = 8;
peg_resolution = 12;
peg_distance = 45;
peg_overlap = 50;
belt_width = 8;

/*[]*/
base_height = 4;
max_overhang_angle = 45;
tolerance = 0.2;
nozzle_diameter = 0.4;
layer_height = 0.2;

/*[Spring]*/
amplitude = 7.5;

// 1 pulse is half a wavelength
pulse_length = 5;
number_of_pulses = 2;
spring_perimeters = 2;

_height = belt_width + base_height;

translate([0, 0.5 * peg_distance, 0])
cylinder(_height, d = peg_diameter, $fn=peg_resolution);

translate([0, -0.5 * peg_distance, 0])
cylinder(_height, d = peg_diameter, $fn=peg_resolution);

translate([0.01 * (100 - peg_overlap) * peg_diameter, 0, 0])
rotate([0, 0, 180])
cylinder(_height, d = peg_diameter, $fn=peg_resolution);

translate([0.01 * (100 - peg_overlap) * peg_diameter, 0, base_height])
hull() {
    rotate([0, 0, 180])
    cylinder(belt_width, d = peg_diameter, $fn=peg_resolution);
    
    translate([0.01 * (100 + peg_overlap) * peg_diameter, 0, 0])
    rotate([0, 0, 180])
    cylinder(belt_width, d = peg_diameter, $fn=peg_resolution);
}

translate([2 * peg_diameter, 0, base_height])
rotate([0, 90, 0])
linear_extrude(42)
polygon([[0, 42], [-1, 45], [-2, 42], [-2, -42], [-1, -45], [0, -42]]);