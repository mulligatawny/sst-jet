Simulation:
  name: NaluSim

linear_solvers:

  - name: solve_scalar
    type: tpetra
    method: gmres
    preconditioner: sgs
    tolerance: 1e-3
    max_iterations: 50
    kspace: 50
    output_level: 0

  - name: solve_cont
    type: tpetra
    method: gmres
    preconditioner: muelu
    tolerance: 1e-3
    max_iterations: 50
    kspace: 50
    output_level: 0
    muelu_xml_file_name: milestone_aspect_ratio_smooth.xml

realms:

  - name: fluidRealm
    mesh: delhi_ndtw.exo
    use_edges: no
    automatic_decomposition_type: rcb

    time_step_control:
     target_courant: 1.0
     time_step_change_factor: 1.2
   
    equation_systems:
      name: theEqSys
      max_iterations: 3 

      solver_system_specification:
        velocity: solve_scalar
        turbulent_ke: solve_scalar
        specific_dissipation_rate: solve_scalar
        pressure: solve_cont
        mixture_fraction: solve_scalar

      systems:
        - LowMachEOM:
            name: myLowMach
            max_iterations: 1
            convergence_tolerance: 1e-5

        - MixtureFraction:
            name: myZ
            max_iterations: 1
            convergence_tolerance: 1e-2

        - ShearStressTransport:
            name: mySST 
            max_iterations: 1
            convergence_tolerance: 1e-5

    initial_conditions:
      - constant: ic_1
        target_name: coflow-HEX
        value:
          pressure: 101325
          velocity: [1.4,0.0,0.0]
          turbulent_ke: 0.0 # come back and fix this
          specific_dissipation_rate: 10
          mixture_fraction: 0.0

        target_name: jet-HEX
        value:
          pressure: 101325
          velocity: [27.7,0.0,0.0]
          turbulent_ke: 0.0 # come back and fix this
          specific_dissipation_rate: 10
          mixture_fraction: 1.0

#      - user_function: ic_2
#        target_name: jet-HEX
#        user_function_name: 
#          velocity: SinProfilePipeFlow
#        user_function_parameters:
#          velocity: [27.7, 1.0,10,10,10]

    material_properties:
      target_name: [jet-HEX, coflow-HEX]
      specifications:

        - name: density
          type: mixture_fraction
          primary_value: 1.1
          secondary_value: 0.92

        - name: viscosity
          type: mixture_fraction
          primary_value: 1.7e-5
          secondary_value: 1.8e-5

    boundary_conditions:

    - inflow_boundary_condition: bc_inflowJet
      target_name: jet_inlet
      inflow_user_data:
        velocity: [2.7,0,0]
        mixture_fraction: 1.0
        turbulent_ke: 0.0 # change this
        specific_dissipation_rate: 10

    - wall_boundary_condition: bc_pipeWall
      target_name: wall
      wall_user_data:
        velocity: [0,0,0]
        turbulent_ke: 0.0
        use_wall_function: no

    - inflow_boundary_condition: bc_inflowX
      target_name: coflow_inlet 
      inflow_user_data:
        velocity: [1.4,0,0]
        mixture_fraction: 0.0
        turbulent_ke: 0.0 # change this
        specific_dissipation_rate: 10

    - symmetry_boundary_condition: bc_top
      target_name: slip_wall
      symmetry_user_data:

    - open_boundary_condition: bc_open
      target_name: outlet
      open_user_data:
        pressure: 101325
        use_total_pressure: yes
        turbulent_ke: 1.0e-12
        specific_dissipation_rate: 1.0e-6

    solution_options:
      name: myOptions
      turbulence_model: sst
      #shift_cvfem_mdot: yes # was in the les, so...

      options:

        - projected_nodal_gradient:
            pressure: element
            velocity: edge
            mixture_fraction: edge

        - hybrid_factor:
            velocity: 1.0 
            turbulent_ke: 1.0
            specific_dissipation_rate: 1.0
            mixture_fraction: 1.0

        - alpha_upw:
            velocity: 1.0 
            mixture_fraction: 1.0

        - laminar_schmidt:
            mixture_fraction: 0.7

        - turbulent_schmidt:
            mixture_fraction: 1.0

#        - source_terms:
#            continuity: density_time_derivative

        - limiter:
            pressure: yes
            velocity: yes
            turbulent_ke: yes
            specific_dissipation_rate: yes
            mixture_fraction: yes

        - projected_nodal_gradient:
            velocity: element 
            pressure: element
            turbulent_ke: element 
            specific_dissipation_rate: element 
    
        - shifted_gradient_operator:
            velocity: no
            pressure: no
            mixture_fraction: no

#        - user_constants:
#            gravity: [9.81,0,0]
#            reference_density: 0.92
#
#        - peclet_function_form:
#            velocity: tanh
#            mixture_fraction: classic
#
#        - peclet_function_tanh_transition:
#            velocity: 1000.0
#            mixture_fraction: 1e9
#
#        - peclet_function_tanh_width:
#            velocity: 25.0

        - input_variables_from_file:
            minimum_distance_to_wall: NDTW

    output:
      output_data_base_name: ./output/jet.e
      output_frequency: 50
      output_node_set: no 
      output_variables:
       - velocity
       - mixture_fraction
       - pressure
       - turbulent_ke
       - specific_dissipation_rate
       - minimum_distance_to_wall
       - sst_f_one_blending
       - turbulent_viscosity
       - minimum_distance_to_wall

    restart:
      restart_data_base_name: ./restart/jet.rst
      restart_frequency: 500
      #restart_time: 1000000

Time_Integrators:
  - StandardTimeIntegrator:
      name: ti_1
      start_time: 0
      time_step: 1.0e-7
      termination_step_count: 500
      time_stepping_type: adaptive
      time_step_count: 0

      realms: 
        - fluidRealm
