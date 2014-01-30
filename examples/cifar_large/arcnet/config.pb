language: PYTHON
name:     "hyp_opt"

variable{
 name: "depth"
 type: INT
 size: 1
 min: 0
 max: 10
 group: 0
}

variable {
 name: "num_units"
 type: INT
 size: 10
 min: 1
 max: 20
 group: 1
 group: 2
 group: 3
 group: 4
 group: 5
 group: 6
 group: 7
 group: 8
 group: 9
 group: 10 
}

variable {
 name: "log_base_epsilon"
 type: FLOAT
 size: 11
 min:  -11.512925464970229
 max:  0.0
 group: 0
 group: 1
 group: 2
 group: 3
 group: 4
 group: 5
 group: 6
 group: 7
 group: 8
 group: 9
 group: 10
}

variable {
 name: "weight_norm"
 type: FLOAT
 size: 11
 min:  0.25
 max:  8
 group: 0
 group: 1
 group: 2
 group: 3
 group: 4
 group: 5
 group: 6
 group: 7
 group: 8
 group: 9
 group: 10
}

#variable {
# name: "dropout"
# type: FLOAT
# size: 11
# min:  0
# max:  0.8
# group: 0
# group: 1
# group: 2
# group: 3
# group: 4
# group: 5
# group: 6
# group: 7
# group: 8
# group: 9
# group: 10
#}


