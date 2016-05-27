-- this is a test
LightInkDef__:register_def_message(2, 806696, "TestDef",
									LightInkTypeDef__.T_Integer, -- int aaaa //this is aaaa
									LightInkTypeDef__.T_ArrayStart, -- array<TestStruct> cccc //this test struct
									-- TestStruct  ////this a struct
									LightInkTypeDef__.T_MapStart, -- map<int,map<int,int>> ddd //this ddddddddd
									LightInkTypeDef__.T_Integer, -- int  //
									LightInkTypeDef__.T_MapStart, -- map<int,int>  //
									LightInkTypeDef__.T_Integer, -- int  //
									LightInkTypeDef__.T_Integer, -- int  //
									LightInkTypeDef__.T_MapEnd, -- map<int,int>  //
									LightInkTypeDef__.T_MapEnd, -- map<int,map<int,int>> ddd //this ddddddddd
									LightInkTypeDef__.T_Integer, -- int aaaa //this aaaa
									LightInkTypeDef__.T_Integer, -- int bbbb //this bbbb
									-- TestStruct  ////this a struct
									LightInkTypeDef__.T_ArrayEnd, -- array<TestStruct> cccc //this test struct
									LightInkTypeDef__.T_MapStart, -- map<int,int> dddd // this test map
									LightInkTypeDef__.T_Integer, -- int  //
									LightInkTypeDef__.T_Integer, -- int  //
									LightInkTypeDef__.T_MapEnd, -- map<int,int> dddd // this test map
									nil)

-- this is a test
LightInkDef__:register_def_message(3, 902006, "TestDef",
									LightInkTypeDef__.T_Integer, -- int bbbb //
									LightInkTypeDef__.T_Integer, -- int cccc //
									LightInkTypeDef__.T_Integer, -- int dddd //
									LightInkTypeDef__.T_Integer, -- int eeee //
									LightInkTypeDef__.T_Integer, -- int ffff //
									LightInkTypeDef__.T_Integer, -- int gggg //
									nil)

