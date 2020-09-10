Simulation:
  name: NaluSim
  time_integrator: ti_1
  optimizer: opt1
  error_estimator: errest_1

linear_solvers:

  - name: solve_scalar
    type: tpetra
    method: gmres
    preconditioner: sgs
    tolerance: 1e-5
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
    recompute_preconditioner: false
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

      systems:

        - LowMachEOM:
            name: myLowMach
            max_iterations: 1
            convergence_tolerance: 1e-5

        - ShearStressTransport:
            name: mySST 
            max_iterations: 1
            convergence_tolerance: 1e-5

    initial_conditions:
      - constant: ic_1
        target_name: coflow-HEX
        value:
          pressure: 0
          velocity: [1.4,0.0,0.0]
          turbulent_ke: 1
          specific_dissipation_rate: 100
        target_name: jet-HEX
        value:
          pressure: 0
          velocity: [27.7,0.0,0.0]
          turbulent_ke: 1
          specific_dissipation_rate: 100
       
    material_properties:
      target_name: [jet-HEX, coflow-HEX]
      specifications:
        - name: density
          type: constant
          value: 1
        - name: viscosity
          type: constant
          value: 1.7e-5

    boundary_conditions:

    - inflow_boundary_condition: bc_inflowJet
      target_name: jet_inlet
      inflow_user_data:
        velocity: [37.6,0.0, 0.0]
        turbulent_ke: 1
        specific_dissipation_rate: 100

    - open_boundary_condition: bc_open
      target_name: outlet
      open_user_data:
        velocity: [0,0]
        pressure: 0.0
        turbulent_ke: 1.0e-12
        specific_dissipation_rate: 1.0e-6

    - symmetry_boundary_condition: bc_symBottom
      target_name: slip_wall
      symmetry_user_data:

    - wall_boundary_condition: bc_wall
      target_name: wall
      wall_user_data:
        velocity: [0,0,0]
        turbulent_ke: 0.0
        use_wall_function: no

    - inflow_boundary_condition: bc_inflowCoflow
      target_name: coflow_inlet
      inflow_user_data:
        velocity: [1.4,0.0, 0.0]
        turbulent_ke: 1
        specific_dissipation_rate: 100

    solution_options:
      name: myOptions
      turbulence_model: sst

      options:
        - hybrid_factor:
            velocity: 1.0 
            turbulent_ke: 1.0
            specific_dissipation_rate: 1.0

        - alpha_upw:
            velocity: 1.0 

        - limiter:
            pressure: no
            velocity: yes 
            turbulent_ke: yes
            specific_dissipation_rate: yes

        - projected_nodal_gradient:
            velocity: element 
            pressure: element
            turbulent_ke: element 
            specific_dissipation_rate: element 
    
        - input_variables_from_file:
            minimum_distance_to_wall: NDTW

    output:
      output_data_base_name: ./output/jet.e
      output_frequency: 500
      output_node_set: no 
      output_variables:
       - velocity
       - pressure
       - pressure_force
       - tau_wall
       - turbulent_ke
       - specific_dissipation_rate
       - minimum_distance_to_wall
       - sst_f_one_blending
       - sst_max_length_scale
       - turbulent_viscosity
       - minimum_distance_to_wall

    post_processing:
    
    - type: surface
      physics: surface_force_and_moment
      output_file_name: post_process_one.dat
      frequency: 500
      parameters: [0,0,0]
      target_name: [wall]

Time_Integrators:
  - StandardTimeIntegrator:
      name: ti_1
      start_time: 0
      time_step: 1.0e-6
      termination_step_count: 500
      time_stepping_type: adaptive
      time_step_count: 0

      realms: 
        - fluidRealm
