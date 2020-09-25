lc = 25e3;
lc_fault = 100;

Fault_length = 16e3;
Fault_width = 15e3;
Fault_dip = 90*Pi/180.;

//Nucleation in X,Z local coordinates
X_nucl = -8e3;
Width_nucl = 10e3;
R_nucl = 1.5e3;
lc_nucl = 200;

Xmax = 60e3;
Xmin = -Xmax;
Ymin = -Xmax +  0.5 * Fault_width  *Cos(Fault_dip);
Ymax =  Xmax + 0.5 * Fault_width  *Cos(Fault_dip);
Zmin = -Xmax;


//Create the Volume
Point(1) = {Xmin, Ymin, 0, lc};
Point(2) = {Xmin, Ymax, 0, lc};
Point(3) = {Xmax, Ymax, 0, lc};
Point(4) = {Xmax, Ymin, 0, lc};
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};
Line Loop(5) = {1,2,3,4};
Plane Surface(1) = {5};
Extrude {0,0, Zmin} { Surface{1}; }

//Create the fault
Point(100) = {-Fault_length, 0 , -Fault_width, lc};
Point(101) = {-Fault_length, 0, 0e3, lc};
Point(102) = {12e3, 0,  0e3, lc};
Point(103) = {12e3, 0, -Fault_width, lc};
Point(106) = {0, 0, 0,  lc} ;
Point(107) = {0, 0,-Fault_width,  lc} ;


Line(100) = {101, 106};
Line(101) = {106, 102};
Line{100,101} In Surface{1};
Line(102) = {102, 103};
Line(103) = {103, 107};
Line(116) = {107,100};
Line(117) = {100,101};



//create nucleation patch
/*
Point(200) = {X_nucl, Width_nucl*Cos(Fault_dip), -Width_nucl  *Sin(Fault_dip), lc_nucl};
Point(201) = {X_nucl, (Width_nucl + R_nucl) * Cos(Fault_dip), -(Width_nucl+R_nucl)  *Sin(Fault_dip), lc_nucl};
Point(202) = {X_nucl + R_nucl, Width_nucl*Cos(Fault_dip), -Width_nucl  *Sin(Fault_dip), lc_nucl};
Point(203) = {X_nucl, (Width_nucl - R_nucl) * Cos(Fault_dip), -(Width_nucl-R_nucl)  *Sin(Fault_dip), lc_nucl};
Point(204) = {X_nucl - R_nucl, Width_nucl*Cos(Fault_dip), -Width_nucl  *Sin(Fault_dip), lc_nucl};
Circle(200) = {201,200,202};
Circle(201) = {202,200,203};
Circle(202) = {203,200,204};
Circle(203) = {204,200,201};
Line Loop(204) = {200,201,202,203};
Plane Surface(200) = {204};
*/

Point(201) = {X_nucl + R_nucl , (Width_nucl + R_nucl) * Cos(Fault_dip), -(Width_nucl+R_nucl)  *Sin(Fault_dip), lc_nucl};
Point(202) = {X_nucl + R_nucl , (Width_nucl - R_nucl) * Cos(Fault_dip), -(Width_nucl-R_nucl)  *Sin(Fault_dip), lc_nucl};
Point(203) = {X_nucl - R_nucl , (Width_nucl - R_nucl) * Cos(Fault_dip), -(Width_nucl-R_nucl)  *Sin(Fault_dip), lc_nucl};
Point(204) = {X_nucl - R_nucl , (Width_nucl + R_nucl) * Cos(Fault_dip), -(Width_nucl+R_nucl)  *Sin(Fault_dip), lc_nucl};
Line(200) = {201, 202};
Line(201) = {202, 203};
Line(202) = {203, 204};
Line(203) = {204, 201};
Line Loop(204) = {200,201,202,203};
Plane Surface(200) = {204};

Line Loop(105) = {100,101,102,103,116,117,200,201,202,203};
Plane Surface(100) = {105};

//create branch
strike = 30*Pi/180 ; 
Fault_length = 12e3 ;
Point(104) = {Fault_length*Cos(strike), -Fault_length*Sin(strike), -Fault_width, lc} ;
Point(105) = {Fault_length*Cos(strike), -Fault_length*Sin(strike), 0,  lc} ;


Line(104) = {106,105} ;
Line(105) = {105,104} ;
Line(106) = {104,107} ;
Line(107) = {107,106} ; // joint line
Line{104} In Surface{1} ;
Line Loop(101) = {107,104,105,106};
Plane Surface(99) = {101};
Ruled Surface(98) = {101};
Line{107} In Surface{100};


//There is a bug in "Attractor", we need to define a Ruled surface in FaceList
Line(114) = {101,102};
Line(115) = {103,100};
Line Loop(106) = {114,102,115,117};
Ruled Surface(101) = {106};
Ruled Surface(201) = {204};

Surface{99,100,200} In Volume{1};


//1.2 Managing coarsening away from the fault
// Attractor field returns the distance to the curve (actually, the
// distance to 100 equidistant points on the curve)
Field[1] = Attractor;
Field[1].FacesList = {101,98};

// Matheval field returns "distance squared + lc/20"
Field[2] = MathEval;
//Field[2].F = Sprintf("0.02*F1 + 0.00001*F1^2 + %g", lc_fault);
//Field[2].F = Sprintf("0.02*F1 +(F1/2e3)^2 + %g", lc_fault);
Field[2].F = Sprintf("0.05*F1 +(F1/2e3)^2 + %g", lc_fault);

//3.4.5 Managing coarsening around the nucleation Patch
Field[3] = Attractor;
Field[3].FacesList = {201};

Field[4] = Threshold;
Field[4].IField = 3;
Field[4].LcMin = lc_nucl;
Field[4].LcMax = lc_fault;
Field[4].DistMin = R_nucl;
Field[4].DistMax = 5*R_nucl;

Field[5] = Restrict;
Field[5].IField = 4;
Field[5].FacesList = {99,100,200} ;

//equivalent of propagation size on element
Field[6] = Threshold;
Field[6].IField = 1;
Field[6].LcMin = lc_fault;
Field[6].LcMax = lc;
Field[6].DistMin = 2*lc_fault;
Field[6].DistMax = 2*lc_fault+0.001;


Field[7] = Min;
Field[7].FieldsList = {2,5,6};


Background Field = 7;

Physical Surface(101) = {1};
Physical Surface(103) = {99,100,200};
//This ones are read in the gui
Physical Surface(105) = {14,18,22,26,27};

Physical Volume(1) = {1};
