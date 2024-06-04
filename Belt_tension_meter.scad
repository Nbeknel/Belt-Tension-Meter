/*[Pegs]*/
peg_diameter = 8;
peg_resolution = 12;
peg_distance = 45;
peg_overlap = 50;
belt_width = 8;

/*[Case]*/
base_height = 4;
max_overhang_angle = 45;
tolerance = 0.2;
nozzle_diameter = 0.4;
layer_height = 0.2;
border_width = 5;

/*[Spring]*/
amplitude = 7.5;
// 1 pulse is half a wavelength
pulse_length = 5;
number_of_pulses = 2;
spring_perimeters = 2;
spring_connection_length = 5;

/*[Vernier]*/
rule_margin = 2;
rule_spacing = 1;
type = "standart";
number_of_subdivisions = 10;

_height = belt_width + base_height + layer_height;
_vernier_length = (2 * number_of_subdivisions - 1) * rule_spacing;

//bottom cylinder
translate([0, 0.5 * peg_distance, 0])
cylinder(_height, d = peg_diameter, $fn=peg_resolution);

//top cylinder
translate([0, -0.5 * peg_distance, 0])
cylinder(_height, d = peg_diameter, $fn=peg_resolution);

//middle cylinder
translate([0.01 * (100 - peg_overlap) * peg_diameter, 0, 0])
rotate([0, 0, 180])
cylinder(_height, d = peg_diameter, $fn=peg_resolution);

//middle cylinder bridge
translate([0.01 * (100 - peg_overlap) * peg_diameter, 0, base_height])
hull() {
    rotate([0, 0, 180])
    cylinder(belt_width, d = peg_diameter, $fn=peg_resolution);
    
    translate([0.01 * (150 + peg_overlap) * peg_diameter, 0, 0])
    rotate([0, 0, 180])
    cylinder(belt_width, d = peg_diameter, $fn=peg_resolution);
}

//spring guide
a = 1.5 * amplitude;
w = 0.5 * belt_width / tan(max_overhang_angle);

translate([2.5 * peg_diameter, 0, base_height])
rotate([0, 90, 0])
linear_extrude(_vernier_length + 2 * rule_margin + nozzle_diameter)
polygon([[0, a], [-0.5 * belt_width, a+w], [-belt_width, a], [-belt_width, -a], [-0.5 * belt_width, -a - w], [0, -a]]);

//vernier scale
translate([2.5 * peg_diameter + rule_margin, a - 5, _height])
for (i = [0 : 1 : 10]){
    translate([i * _vernier_length / number_of_subdivisions, 0, 0])
    cube([nozzle_diameter, 5, layer_height]);
}

//case
translate([2.5 * peg_diameter - border_width, 0, 0])
difference() {
    translate([0, -a - tolerance - border_width, 0])
    cube([_vernier_length + 2 * (rule_margin + border_width + spring_connection_length) + nozzle_diameter + pulse_length * number_of_pulses, 2 * (a + tolerance + border_width), _height]);
    
    translate([0, 0, base_height])
    rotate([0, 90, 0])
    linear_extrude(_vernier_length + 2 * (rule_margin + spring_connection_length) + nozzle_diameter + pulse_length * number_of_pulses + border_width)
    polygon([[0, a + tolerance], [-0.5 * belt_width, a+w+tolerance], [-belt_width, a+tolerance], [-belt_width, -a-tolerance], [-0.5 * belt_width, -a - w-tolerance], [0, -a-tolerance]]);
}