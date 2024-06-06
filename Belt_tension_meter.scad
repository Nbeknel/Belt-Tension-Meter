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
module peg(x=0, y=0, z=0, rot = 0) {
    translate([x, y, z])
    rotate([0, 0, rot])
    cylinder(_height, d = peg_diameter, $fn=peg_resolution);
}

//middle cylinder bridge
module bridge() {
    translate([0.01 * (100 - peg_overlap) * peg_diameter, 0, base_height + layer_height])
    hull() {
        rotate([0, 0, 180])
        cylinder(belt_width, d = peg_diameter, $fn=peg_resolution);
    
        translate([0.01 * (150 + peg_overlap) * peg_diameter, 0, 0])
        rotate([0, 0, 180])
        cylinder(belt_width, d = peg_diameter, $fn=peg_resolution);
    }
}

//spring guide
module slider(x, y, z, angle) {
    a = y;
    w = 0.5 * z / tan(angle);
    rotate([0, 90, 0])
    linear_extrude(x)
    polygon([[0, a], [-0.5 * z, a+w], [-z, a], [-z, -a], [-0.5 * z, -a - w], [0, -a]]);
}

//vernier scale
module vernier_scale() {
    translate([2.5 * peg_diameter + rule_margin, 1.5 * amplitude - 5, _height])
    for (i = [0 : 1 : 10]){
        translate([i * _vernier_length / number_of_subdivisions, 0, 0])
        cube([nozzle_diameter, 5, layer_height]);
    }
}

//case
/*
translate([2.5 * peg_diameter - border_width - tolerance, 0, 0])
difference() {
    translate([0, -a - tolerance - border_width, 0])
    cube([_vernier_length + 2 * (rule_margin + border_width + spring_connection_length) + nozzle_diameter + pulse_length * number_of_pulses + tolerance, 2 * (a + tolerance + border_width), _height]);
    
    translate([border_width, 0, base_height + layer_height])
    rotate([0, 90, 0])
    linear_extrude(_vernier_length + 2 * (rule_margin + spring_connection_length) + nozzle_diameter + pulse_length * number_of_pulses)
    polygon([
        [layer_height, a + tolerance],
        [-0.5 * belt_width, a+w+tolerance],
        [-belt_width - layer_height, a+tolerance],
        [-belt_width - layer_height, -a-tolerance],
        [-0.5 * belt_width, -a - w-tolerance],
        [layer_height, -a-tolerance]
    ]);
}*/

module chamfer_object(r, fn=4) {
    translate([r, 0, r])
    union() {
        cylinder(r, r, 0, $fn=fn);
        
        translate([0, 0, -r])
        cylinder(r, 0, r, $fn=fn);
    }
}

module case_a(chamfer_radius) {
    x = _vernier_length + 2 * (rule_margin + border_width + spring_connection_length - chamfer_radius) + nozzle_diameter + pulse_length * number_of_pulses + tolerance;
    y = 2 * (tolerance + border_width - chamfer_radius) + 3 * amplitude;
    z = _height - 2 * chamfer_radius;
    hull() {
        for (i = [0 : 1 : 1],
            j = [0 : 1 : 1],
            k = [0 : 1 : 1]) {
                translate([i * x, (j - 0.5) * y, k * z])
                chamfer_object(chamfer_radius, 20);
            }
    }
}

module case_w_guide() {
    difference() {
        children();
        
        translate([border_width, 0, base_height + layer_height - tolerance])
        slider(_vernier_length + 2 * (rule_margin + spring_connection_length) + nozzle_diameter + pulse_length * number_of_pulses, //x
            1.5 * amplitude + tolerance, //y
            belt_width + 2 * tolerance, //z
            max_overhang_angle //angle
        );
    }
}

module case(){
    case_w_guide(){
        case_a(2);
    }
}

module belt_tension_meter(){
    union() {
        // top peg
        peg(y = 0.5 * peg_distance);
        
        // middle peg
        peg(x = 0.01 * (100 - peg_overlap) * peg_diameter, rot = 180);
        
        // bottom cylinder
        peg(y = -0.5 * peg_distance);
        
        // bridge
        bridge();
        
        translate([2.5 * peg_diameter, 0, base_height + layer_height])
        slider(_vernier_length + 2 * rule_margin + nozzle_diameter, //x
            1.5 * amplitude, //y
            belt_width, //z
            max_overhang_angle //angle
        );
        
        vernier_scale();
        
        translate([2.5 * peg_diameter - border_width - tolerance, 0, 0])
        case();
    }
}

belt_tension_meter();