-- Control send Cmd to Loader
LightInkDef__:register_def_message(2, 548118, "ControlCmdLineLoader",
									LightInkTypeDef__.T_String, -- string cmdLine //
									nil)

-- Control send Cmd to Loader
LightInkDef__:register_def_message(1, 53798, "ControlCmdLineLoader",
									LightInkTypeDef__.T_String, -- string result //login result
									nil)

-- Control kill Loader
LightInkDef__:register_def_message(2, 636166, "ControlKillLoader",
									nil)

-- Control Login Loader
LightInkDef__:register_def_message(2, 365042, "ControlLoginLoader",
									LightInkTypeDef__.T_String, -- string user //
									LightInkTypeDef__.T_String, -- string password //
									nil)

-- Control Login Loader
LightInkDef__:register_def_message(1, 927532, "ControlLoginLoader",
									LightInkTypeDef__.T_String, -- string result //login result
									nil)

