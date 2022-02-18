#version 3.7;

/*
	@Title: Ice Cream Factory
	@Author: João Henggeler
	@Date: 2021-11-15
	@Version: 1.0
*/

#include "colors.inc"
#include "consts.inc"
#include "metals.inc"
#include "rand.inc"
#include "shapes3.inc"
#include "transforms.inc"

global_settings
{
	assumed_gamma 1.0
}

#default
{
	finish {ambient 0.1 diffuse 0.9}
}

#ifndef(Debug)
	#declare Debug = no;
#end

#declare O_Debug = sphere
{
	o, 0.1
	pigment {color Red}
	finish {ambient 1 diffuse 0}
}

//////////////////////////////////////////////////
////////////////////////////////////////////////// Camera and Lights
//////////////////////////////////////////////////

//location <2, 13, 2>
//look_at <1, 12, 1>

// <11, 15, 11>
// <-10, 0, -10>

// @Animation
#declare Camera_Location = vrotate(<11, 15, 11>, 360*clock*y);
#declare Camera_Look_At = vrotate(<-10, 0, -10>, 360*clock*y);
#declare Light_Position = vrotate(15*x + 15*y, 360*clock*y);

camera
{
	location Camera_Location
	look_at Camera_Look_At
}                    

light_source
{
	Light_Position
	color White*0.9
	
	#if(Debug)
		looks_like {O_Debug}
	#end
}

//////////////////////////////////////////////////
////////////////////////////////////////////////// Ice Cream Scoops
//////////////////////////////////////////////////


#declare Scoops_Bottom_Radius = 2.3;
#declare Scoops_Middle_Radius = 1.5;
#declare Scoops_Top_Radius = 1.0;
#declare Scoops_Overlap = 0.2;
#declare Scoops_Base_Height = 2.5;

#declare TR_Scoops_Bottom 	= transform {scale Scoops_Bottom_Radius 	translate Scoops_Base_Height*y 	translate Scoops_Bottom_Radius*y}
#declare TR_Scoops_Middle 	= transform {scale Scoops_Middle_Radius 	translate Scoops_Base_Height*y 	translate (2*Scoops_Bottom_Radius + Scoops_Overlap*Scoops_Middle_Radius)*y}
#declare TR_Scoops_Top 		= transform {scale Scoops_Top_Radius 		translate Scoops_Base_Height*y 	translate (2*Scoops_Bottom_Radius + (1.0 + Scoops_Overlap)*Scoops_Middle_Radius + Scoops_Overlap*Scoops_Top_Radius)*y}

#declare T_Scoops = texture
{
	normal {agate 0.25 scale 0.5}
	finish {phong 0.5}   
}

// @Source: https://www.color-hex.com/color-palette/660
#declare C_Strawberry = srgb <255, 197, 217> / 255;
#declare C_Chocolate = srgb <151, 119, 103> / 255;
#declare C_Vanilla = srgb <253, 245, 201> / 255;
#declare C_Mint = srgb <194, 242, 208> / 255;
#declare C_Caramel = srgb <255, 203, 133> / 255;

union
{
	sphere
	{
		o, 1
		texture {T_Scoops}
		pigment {color C_Strawberry}
		transform TR_Scoops_Bottom
	}
	
	sphere
	{
		o, 1
		texture {T_Scoops}
		pigment {color C_Chocolate}
		transform TR_Scoops_Middle
	}
	
	sphere
	{
		o, 1
		texture {T_Scoops}
		pigment {color C_Vanilla}
		transform TR_Scoops_Top
	}	
}

//////////////////////////////////////////////////
////////////////////////////////////////////////// Caramel Topping
//////////////////////////////////////////////////

// Adapted from Friedrich A. Lohmüller's "Spherical Spirals 1".
// @Source: http://www.f-lohmueller.de/pov_tut/loop/povlup9e.htm
#declare Topping_Num_Spheres = (Debug ? 100 : 6000);
#declare Topping_Sphere_Radius = 0.03;
#declare Topping_Swirl_Step = 15;

merge
{
	#for(Idx, 0, Topping_Num_Spheres-1)
	
		sphere
		{
			o, Topping_Sphere_Radius

			pigment {color C_Caramel filter 0.8}
			finish {phong 1}
			
			translate Scoops_Top_Radius*x
			rotate (Idx * 180/Topping_Num_Spheres)*z
			rotate (Topping_Swirl_Step*Idx * 360/Topping_Num_Spheres)*y
		}
	
	#end
	
	transform TR_Scoops_Top
}

//////////////////////////////////////////////////
////////////////////////////////////////////////// Cherry
//////////////////////////////////////////////////

// Adapted from Mike Williams' "Isosurface Tutorial". Removed the stem from the equation so we could add our own.
// @Source: https://web.archive.org/web/20200129140707/http://www.econym.demon.co.uk/isotut/printable.htm#CH_real
#declare Apple_R1 = 4;
#declare Apple_R2 = 3.8;
#declare FN_Apple_X = function(u,v) {cos(u)*(Apple_R1 + Apple_R2*cos(v))}
#declare FN_Apple_Y = function(u,v) {sin(u)*(Apple_R1 + Apple_R2*cos(v)) + 0.25*cos(5*u)}
#declare FN_Apple_Z = function(u,v) {-1.6*ln(1 - v*0.3157) + 6*sin(v) +2*cos(v)}

#declare Cherry_Angle = 15;
#declare Cherry_Vertical_Offset = 0.05;
#declare C_Cherry = srgb <172, 0, 0> / 255;
#declare C_Stem = srgb <114,165,24> / 255;

#declare O_Cherry = union
{
	// Cherry
	parametric
	{
		function {FN_Apple_X(u,v)}
		function {FN_Apple_Y(u,v)}
		function {FN_Apple_Z(u,v)}
		<0, -pi>, <2*pi, pi>
		
		contained_by {box{<-7.9, -7.9, -7.5> <7.9, 7.9, 9.1>}}
		accuracy 0.0001
		precompute 18, x, y, z
		
		pigment {color C_Cherry}
		finish {phong 0.8}
		
		scale 0.06
		rotate -90*x
	}
	
	// Stem
	sphere_sweep
	{
		b_spline
		7,
		
		0.0*z + 0.0*y, 0.03
		0.2*z + 0.8*y, 0.03
		0.4*z + 1.6*y, 0.03
		0.7*z + 2.3*y, 0.03
		1.0*z + 2.6*y, 0.04
		1.5*z + 2.8*y, 0.05
		2.0*z + 3.0*y, 0.06
		
		pigment {color C_Stem}
		finish {phong 0.6}
		
		// Move the stem to the center.
		translate -0.7*y -0.25*z
	}
}

object
{
	O_Cherry
	rotate Cherry_Angle*x
	transform TR_Scoops_Top
	translate (Scoops_Top_Radius + Cherry_Vertical_Offset)*y	
}

//////////////////////////////////////////////////
////////////////////////////////////////////////// Bowl
//////////////////////////////////////////////////

// @Source: https://www.color-hex.com/color-palette/5361
#declare C_Plastic_Red = srgb <255, 179, 186> / 255 filter 0.5;
#declare C_Plastic_Orange = srgb <255, 223, 186> / 255 filter 0.5;
#declare C_Plastic_Yellow = srgb <255, 255, 186> / 255 filter 0.5;
#declare C_Plastic_Green = srgb <186, 255, 201> / 255 filter 0.5;
#declare C_Plastic_Blue = srgb <186, 225, 255> / 255 filter 0.5;
#declare C_Plastic_White = rgbf <1, 1, 1, 0.5>;

sor
{
	11,
	
	<0.0, -0.5>, // Base
	<1.5,  0.0>,
	<1.0,  0.2>,
	
	<0.5,  0.4>, // Stem
	<0.5,  2.4>, // Ice Cream Base
	<1.0,  2.6>,
	
	<2.0,  3.0>, // Side
	<2.5,  3.2>,
	
	<3.0,  5.6>, // Top
	<3.5,  5.8>,
	<4.0,  6.0>
	
	open
	
	pigment {color C_Plastic_Blue}
	finish {specular 1}
}

//////////////////////////////////////////////////
////////////////////////////////////////////////// Sprinkles
//////////////////////////////////////////////////

#declare Sprinkle_Length = 0.2;
#declare Sprinkle_Radius = 0.05;
#declare O_Sprinkle = union
{
	cylinder
	{
		o, Sprinkle_Length*z, Sprinkle_Radius
	}
	
	sphere
	{
		o, Sprinkle_Radius
	}
	
	sphere
	{
		Sprinkle_Length*z, Sprinkle_Radius
	}
	
	finish {phong 1 phong_size 15}
	
	// Center at the middle of the cylinder.
	translate -0.5*Sprinkle_Length*z
}

#declare Sprinkles_Min_Height = 5.5;
#declare RND_Sprinkles = seed(1234567890);

#declare Num_Scoops = 3;
#declare A_Scoops_Transforms = array[Num_Scoops] {TR_Scoops_Bottom, TR_Scoops_Middle, TR_Scoops_Top};
#declare A_Scoops_Sprinkles = array[Num_Scoops] {200, 200, 30};

#declare Sprinkles_Num_Colors = 5;
#declare A_Sprinkles_Colors = array[Sprinkles_Num_Colors] {Red, Orange, Yellow, Green, Blue};
#declare Sprinkles_Color_Idx = 0;

#for(Scoops_Idx, 0, Num_Scoops-1)

	#local Num_Sprinkles = A_Scoops_Sprinkles[Scoops_Idx];
	#local TR_Ball = A_Scoops_Transforms[Scoops_Idx];
	#local V_Scoops_Center = vtransform(o, TR_Ball);

	#for(Sprinkle_Idx, 1, Num_Sprinkles)
		
		#local V_Sprinkle = o;

		#while(V_Sprinkle.y < Sprinkles_Min_Height)
			#local V_Sprinkle = VRand_On_Sphere(RND_Sprinkles);
			#local V_Sprinkle = vtransform(V_Sprinkle, TR_Ball);
		#end
		
		#local C_Sprinkle = A_Sprinkles_Colors[Sprinkles_Color_Idx];
		#declare Sprinkles_Color_Idx = mod(Sprinkles_Color_Idx + 1, Sprinkles_Num_Colors);
		
		#local V_To_Center = (V_Sprinkle - V_Scoops_Center);

		object
		{
			O_Sprinkle
			pigment {color C_Sprinkle}
			Point_At_Trans(V_To_Center)
			translate V_Sprinkle
		}
		
	#end

#end

//////////////////////////////////////////////////
////////////////////////////////////////////////// Fan Definition
//////////////////////////////////////////////////

#declare Fan_Threshold = 0.65;
#declare Fan_Strength = 1.0;

#declare Fan_Center_Height = 2.0;

#declare Fan_Blade_Thickness = 0.5;
#declare Fan_Blade_Angle = -30;
#declare Fan_Blade_Center_Offset = 1.25;
#declare Fan_Num_Blades = 6;

#declare C_Fan_Center = White * 0.7;
#declare C_Fan_Blade_1 = C_Plastic_White;
#declare C_Fan_Blade_2 = C_Plastic_Red;

#declare O_Fan = blob
{
	threshold Fan_Threshold
	
	sphere
	{
		o, 1, Fan_Strength
		pigment {color C_Fan_Center}
		finish {phong 1}
		scale <1, Fan_Center_Height, 1>
	}

	#for(Idx, 0, Fan_Num_Blades-1)
	
		cylinder
		{
			o, z, 1, Fan_Strength
			
			pigment
			{
				spiral1 2
				color_map
				{
					[0.0 color C_Fan_Blade_1]
					[0.5 color C_Fan_Blade_1]
					[0.5 color C_Fan_Blade_2]
					[1.0 color C_Fan_Blade_2]
				}
			}
			finish {phong 1}
				
			scale <1, Fan_Blade_Thickness, 1>
			rotate Fan_Blade_Angle*z
			translate Fan_Blade_Center_Offset*z
			rotate (Idx * 360/Fan_Num_Blades)*y
		}
	
	#end
	
	scale 1.5
	rotate 90*z
}

//////////////////////////////////////////////////
////////////////////////////////////////////////// Walls
//////////////////////////////////////////////////

#declare Wall_Out_Radius = 36;
#declare Wall_In_Radius = 16;
#declare Wall_Height = 100;

#declare Num_Fans = 7;
#declare Fan_Height = 8;
#declare Fan_Wall_Angle_Offset = 20;

// @Animation: Oscillate between two values.
#declare Fan_Wall_Distance_Min = -1;
#declare Fan_Wall_Distance_Max = 6;
#declare Fan_Wall_Distance_Offset = 0.5 * ( (Fan_Wall_Distance_Max - Fan_Wall_Distance_Min) * cos(2*pi*clock + pi) + Fan_Wall_Distance_Max + Fan_Wall_Distance_Min );

#declare Fan_Hole_Radius = 4.5;
#declare Mount_Hole_Radius = 1.0;

#declare C_Wall = srgb <35, 125, 185> / 255;
#declare C_Wall_Notch = C_Wall * 0.9;

difference
{
	object
	{
		Rounded_Tube(Wall_Out_Radius, Wall_In_Radius, 0.1, Wall_Height, no)
		pigment {color C_Wall}
	}
	
	#for(Idx, 0, Num_Fans-1)

		sphere
		{
			o, Fan_Hole_Radius
			pigment {color C_Wall_Notch}
			translate Fan_Height*y + Wall_In_Radius*z
			rotate (Fan_Wall_Angle_Offset + Idx * 360/Num_Fans)*y
		}
		
		cylinder
		{
			o, Wall_Out_Radius*z, Mount_Hole_Radius
			pigment {color C_Wall_Notch}
			translate Fan_Height*y
			rotate (Fan_Wall_Angle_Offset + Idx * 360/Num_Fans)*y
		}
	
	#end
}

//////////////////////////////////////////////////
////////////////////////////////////////////////// Floor
//////////////////////////////////////////////////

#declare C_Tile_1 = srgb <24, 87, 129> / 255;
#declare C_Tile_2 = White;

plane
{
	y, 0
	pigment {checker C_Tile_1 C_Tile_2}
	finish {ambient 0.6 diffuse 0.4 reflection 0.5}
}

//////////////////////////////////////////////////
////////////////////////////////////////////////// Floor Ring
//////////////////////////////////////////////////

#declare Floor_Ring_Major_Radius = Wall_In_Radius;
#declare Floor_Ring_Minor_Radius = 0.2;

torus
{
	Floor_Ring_Major_Radius, Floor_Ring_Minor_Radius
	texture {T_Gold_1C}
}

//////////////////////////////////////////////////
////////////////////////////////////////////////// Fan Mount and Ring Definitions
//////////////////////////////////////////////////

#declare Mount_Radius = Mount_Hole_Radius*0.25;
#declare Mount_Num_Diffs = 2000;
#declare Mount_Diff_Radius = 0.15;
#declare Mount_Diff_Angle_Step = 45;

#declare O_Mount = difference
{
	cylinder
	{
		o, Wall_Out_Radius*z, Mount_Radius
		pigment {C_Fan_Center}
		finish {phong 0.6}
	}
	
	#for(Idx, 0, Mount_Num_Diffs)
		sphere
		{
			o, Mount_Diff_Radius
			pigment {color C_Cherry}
			finish {phong 0.6}
			translate Mount_Radius*y + (Idx / Mount_Num_Diffs)*Wall_Out_Radius*z
			rotate (Idx * 360/Mount_Num_Diffs)*Mount_Diff_Angle_Step*z
		}
	#end
}

#declare Mount_Ring_Major_Radius = Mount_Radius;
#declare Mount_Ring_Minor_Radius = 0.05;

#declare O_Mount_Ring = torus
{
	Mount_Ring_Major_Radius, Mount_Ring_Minor_Radius
	texture {T_Copper_1A}
	normal {radial frequency 15}
	rotate 90*x
}

//////////////////////////////////////////////////
////////////////////////////////////////////////// Fans and Mounts
//////////////////////////////////////////////////

// @Animation
#declare Fan_Rotation = 20 * -360*clock;

#for(Idx, 0, Num_Fans-1)

	object
	{
		O_Fan
		rotate Fan_Rotation*x
		rotate -90*y
		translate Fan_Height*y + (Wall_In_Radius - Fan_Wall_Distance_Offset - Fan_Center_Height/2)*z
		rotate (Fan_Wall_Angle_Offset + Idx * 360/Num_Fans)*y
	}

	object
	{
		O_Mount
		rotate Fan_Rotation*z
		translate Fan_Height*y + (Wall_In_Radius - Fan_Wall_Distance_Offset)*z
		rotate (Fan_Wall_Angle_Offset + Idx * 360/Num_Fans)*y
	}
	
	object
	{
		O_Mount_Ring
		rotate Fan_Rotation*z
		translate Fan_Height*y + (Wall_In_Radius - Fan_Wall_Distance_Offset + 0.2)*z
		rotate (Fan_Wall_Angle_Offset + Idx * 360/Num_Fans)*y
	}
	
#end