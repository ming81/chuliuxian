Shader "Unlit/chuliuxiang"
{
	Properties
	{
		sBaseSampler ("sBaseSampler", 2D) = "white" {}
		cBaseMapBias("cBaseMapBias",RANGE(0,1)) = 0
		sMixSampler ("sMixSampler", 2D) = "white" {}
		sNormalSampler ("sNormalSampler", 2D) = "white" {}
		sDetailNormalSampler ("sDetailNormalSampler", 2D) = "white" {}
		cDetailUVScale("cDetailUVScale",float) = 1
		sLutMapSampler ("sLutMapSampler", 2D) = "white" {}
		sEnvSampler ("sEnvSampler", 2D) = "white" {}
		sShadowMapSampler ("sShadowMapSampler", 2D) = "white" {}
		sEmissionSampler ("sEmissionSampler", 2D) = "white" {}

		_SkinSpec_color1("_SkinSpec_color1", Color) = (1,1,1,1)
		_SkinSpec_color2("_SkinSpec_color2", Color) = (1,1,1,1)
		EmssionColor("EmssionColor", Color) = (1,1,1,1)
		CameraPosPS("CameraPosPS",float) = 0
		Lights0("Lights0",Vector) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"


			sampler2D _MainTex;
			float4 _MainTex_ST;

			//v
			uniform float4x4 ViewProjVS;
			uniform float4 CameraPosVS;
			uniform float4x4 LightViewProjTex;
			uniform float4 FogInfo;
			uniform float4 SK[192]; //SkeletonData
			uniform float4x4 World;

			//f

			uniform float CameraPosPS;
			uniform float4 EnvInfo;
			uniform float3 SunColor;
			uniform float3 LightDir;
			uniform float4 FogColor;
			uniform float4 ShadowColor;
			uniform float4 FogColor2;
			uniform float4 FogColor3;
			uniform float4 Lights0[4];
			uniform float4 Lights1[4];
			uniform float4 cShadowBias;
			uniform float4 cPointCloud[6];
			uniform float4 cVirtualLitDir;
			uniform float3 cVirtualLitColor;

			uniform float maokong_intensity;
			uniform float cEnvStrength;
			uniform float RoughnessOffset1;
			uniform float RoughnessOffset2;
			uniform float cDetailUVScale;
			uniform float cSSSIntensity;
			uniform float cBaseMapBias;
			uniform float cNormalMapBias;

			uniform float4 EmssionColor;
			uniform float3 _SkinSpec_color1;
			uniform float3 _SkinSpec_color2;
			uniform float4 cSSSColor;

			uniform sampler2D sBaseSampler;
			uniform sampler2D sMixSampler;
			uniform sampler2D sNormalSampler;
			uniform sampler2D sDetailNormalSampler;
			uniform sampler2D sLutMapSampler;
			uniform samplerCUBE sEnvSampler;
			uniform sampler2D sShadowMapSampler;
			uniform sampler2D sEmissionSampler;

			struct vertexin{

			float4 position : POSITION;
			float4 normal: NORMAL;
			float4 tangent: TANGENT;
			float2 uv : TEXCOORD0;				
			float2 texcoord0: TEXCOORD0;
			float4 BID:TEXCOORD1;//BLENDINDICES
			float4 BW: TEXCOORD2;//BlendWeight

			float4 color:COLOR;
			//	in  float4 POSITION;
			//	in  float4 COLOR;
			//	in  float2 TEXCOORD0;			
			//	in  float4 BINORMAL;
			//	in  float4 v.BW;
			//	in   float4 v.BID;				
			};

struct vertexout
{
	//float2 uv : TEXCOORD0;			
	float4 position : SV_POSITION;			
	float2 uv0:TEXCOORD0;//TEXCOORD0	
	float4 posWorld:TEXCOORD1;//xlv_TEXCOORD1:TEXCOORD1;	
	float3 normaldir:TEXCOORD2;//float2 TEXCOORD2:TEXCOORD2;	
	float4 xlv_TEXCOORD3:TEXCOORD3; 

	float3 tangentDir:TEXCOORD4; //	float2 TEXCOORD4:TEXCOORD4;	
	float3 bitangentDir:TEXCOORD5;//float2 TEXCOORD5:xlv_TEXCOORD5	
	float4 xlv_TEXCOORD6:TEXCOORD6;

	float4 xlv_COLOR:Color;
	float4 xlv_TEXCOORD7:TEXCOORD7;									
};


vertexout vert (vertexin v)
{
	vertexout o;
	//o.position = float4(0,0,0,0);
	float4 vertex= float4(v.position.xyz,1);
	// 将法线向量转换为范围[-1,1] //normal
	float3 NormalDir = (v.normal.xyz * 2.0) - 1.0;
	float3 TangentDir = normalize(v.tangent.xyz);
	float3 BinormalDir = cross(NormalDir,TangentDir);			


	int idx_8 = v.BID.x;
	int idx_9 = v.BID.y;
	int idx_10 = v.BID.z;
	int idx_11 = v.BID.w;

	float4 BoneVertex1 = ((((v.BW.x * SK[(3 * idx_8)])+ (v.BW.y * SK[(3 * idx_9)])) + (v.BW.z * SK[(3 * idx_10)])) + (v.BW.w * SK[(3 * idx_11)]));
	float4 BoneVertex2 = ((((v.BW.x * SK[((3 * idx_8) + 1)])+ (v.BW.y * SK[((3 * idx_9) + 1)])) + (v.BW.z * SK[((3 * idx_10) + 1)])) + (v.BW.w * SK[((3 * idx_11)+ 1)]));
	float4 BoneVertex3 = ((((v.BW.x * SK[((3 * idx_8) + 2)]) + (v.BW.y * SK[((3 * idx_9) + 2)]))+ (v.BW.z * SK[((3 * idx_10) + 2)])) + (v.BW.w * SK[((3 * idx_11)+ 2)]));

////bonevertexspace
	float3 BoneVertexSpace = (dot (BoneVertex1.xyz, vertex.xyz), dot (BoneVertex2.xyz, vertex.xyz) ,dot (BoneVertex3.xyz, vertex.xyz));
	float3 BonePosition = (BoneVertex1.w,BoneVertex2.w,BoneVertex3.w);
	float4 NewBonePositon1 = ((BoneVertexSpace + BonePosition), vertex.w);

///////vertex btn
	float3 BoneNormal = (dot (BoneVertex1.xyz, NormalDir) ,dot (BoneVertex2.xyz, NormalDir) , dot (BoneVertex3.xyz, NormalDir)); 
	float3 BoneTangent = ( dot (BoneVertex1.xyz, TangentDir),dot (BoneVertex2.xyz, TangentDir)  ,dot (BoneVertex3.xyz, TangentDir));
	float3 BoneBinormal = (dot (BoneVertex1.xyz, BinormalDir), dot (BoneVertex2.xyz, BinormalDir) , dot (BoneVertex3.xyz, BinormalDir));
///conver GPu Skin


	///conver space
	float3 GPUSKINNormalSpace = ((v.color.zyx * 2.0) - 1.0);

	float3 GPUSKINNormal = ( -(GPUSKINNormalSpace.x) ,GPUSKINNormalSpace.z , GPUSKINNormalSpace.y );

	float3 GPUSKINVertex = (dot (BoneVertex1.xyz, GPUSKINNormal) , dot (BoneVertex2.xyz, GPUSKINNormal) ,dot (BoneVertex3.xyz, GPUSKINNormal));

	GPUSKINNormalSpace = GPUSKINVertex;

	float4 viewDirection;			
	float4 tmpvar_25;

	float4 Obj2World = (mul(World,NewBonePositon1).xyz,1);

	float3x3 WorldSpace = {World[0].xyz , World[1].xyz , World[2].xyz};

	float3 Obj2WorldNormal= normalize(mul(WorldSpace,BoneNormal));

	float3x3 WorldSpace1 = {World[0].xyz,World[1].xyz, World[2].xyz};

	float3x3 WorldSpace2 = {World[0].xyz,World[1].xyz, World[2].xyz};

	float3x3 WorldSpace3 = {World[0].xyz,World[1].xyz, World[2].xyz};		

	tmpvar_25.xyz = normalize(mul( WorldSpace3,GPUSKINVertex));


	viewDirection.xyz = (Obj2World.xyz - CameraPosVS.xyz);

	float Fogv  = clamp (((Obj2World.y * FogInfo.z) + FogInfo.w), 0.0, 1.0); 

	float  fHeightCoef_32 = (Fogv * Fogv);

	fHeightCoef_32 = (fHeightCoef_32 * fHeightCoef_32);

	float view = (1.0 - exp((-(max (0.0, (sqrt(dot (viewDirection.xyz, viewDirection.xyz)) - FogInfo.x)))
		                                  * max ((FogInfo.y * fHeightCoef_32), (0.1 * FogInfo.y)))));


	viewDirection.w = (view * view);

	float4 RainColor = float4(0.0, 0.0, 0.0,0.0);
	
	float4 tmpvar_35;
	float4 tmpvar_36;

	float4 tmpvar_37 = (Obj2World.xyz,1);

	tmpvar_35 =mul( ViewProjVS,tmpvar_37);

	//o.position.xyw = tmpvar_35.xyw;  //gl_Position.xyw = tmpvar_35.xyw;
	o.uv0 = v.texcoord0; //xlv_TEXCOORD0 = TEXCOORD0.xyxy;

	//xlv_TEXCOORD1 = Obj2World;
	o.posWorld = Obj2World;
	//xlv_TEXCOORD2 = Obj2WorldNormal;
	o.normaldir = Obj2WorldNormal;

	o.xlv_TEXCOORD3 = viewDirection;

	//o.xlv_TEXCOORD4 
	o.tangentDir =  normalize(clamp (mul(WorldSpace1,BoneTangent), -2, 2));
	//o.xlv_TEXCOORD5
	o.bitangentDir = normalize(clamp (mul(WorldSpace2,BoneBinormal), -2, 2));

	o.xlv_TEXCOORD6 = RainColor;

	o.xlv_TEXCOORD7 = mul(LightViewProjTex,Obj2World);

	o.xlv_COLOR = tmpvar_25;

	//gl_Position.z = ((tmpvar_35.z * 2.0) - tmpvar_35.w);//

	//o.position.z = ((tmpvar_35.z * 2.0) - tmpvar_35.w);

	//o.position = float4(tmpvar_35.xy, (tmpvar_35.z * 2.0) - tmpvar_35.w, tmpvar_35.w);
	// o.normalDir = UnityObjectToWorldNormal(v.normal.xyz);
	o.posWorld = mul(unity_ObjectToWorld, vertex);
	o.position = UnityObjectToClipPos(vertex);
	return o;
}

fixed4 frag (vertexout i) : SV_Target{
	float2 uv0 = i.uv0;
	float3 normaldir = i.normaldir;
	float3 tangentDir = i.tangentDir;
	float3 bitangentDir = i.bitangentDir;
	float4 xlv_COLOR = i.xlv_COLOR;
	float4 xlv_TEXCOORD3 = i.xlv_TEXCOORD3;
	float4 xlv_TEXCOORD7 = i.xlv_TEXCOORD7;
	float4 posWorld = i.posWorld;



	float4 emission_3;

	float specularMask_5;
	float3 SpecRadiance_6;
	float3 DiffuseIrradiance_7;
	
	float inShadow_9;
	float shadow_10;
	
	float vertexColorW_15;
	

	float Roughness_18;

	///Diffuse
	float4 Basesampler_var = tex2Dbias (sBaseSampler, float4(uv0.xy,0,cBaseMapBias));
	float3 Diffuse = Basesampler_var.xyz;
	float4 BaseColor = ( Diffuse * Diffuse , Basesampler_var.a);  
	float Roughness =  max ((1.0 - Basesampler_var.a), 0.03);


	float tmpvar_23 = (EnvInfo.x * 0.5);

	float rain_22 = tmpvar_23;

	float RainColor = clamp ((((3.0 * normaldir.y)+ 0.2) + (0.1 * rain_22)), 0.0, 1.0);

	rain_22 = (1.0 - (rain_22 * RainColor));


	float tmpvar_25 = clamp ((rain_22 * Roughness), 0.05, 1.0);

	Roughness_18 = tmpvar_25;

	float4 MaksTex = tex2D (sMixSampler, uv0.xy);

	BaseColor.xyz = ((BaseColor.xyz * (1.0 - MaksTex.a)) + ((BaseColor.xyz * float3(1.35, 1.2, 1.3)) * MaksTex.a));	

	
	

	float Ma = (1.0 - MaksTex.a);


	////Normal
	float4 NormalTex =  tex2Dbias (sNormalSampler, float4 (uv0,0, cNormalMapBias));

	float4 BaseNormal = NormalTex;
	// 将法线向量转换为范围[-1,1]
	// BaseNormal.xyz = ((BaseNormal.xyz * 2.0) - 1.0);
	BaseNormal.xyz = UnpackNormal(BaseNormal);

	float4 DetailNormalMap = tex2D (sDetailNormalSampler, (uv0 * cDetailUVScale));
	float3 DetailNormal = UnpackNormal((DetailNormalMap.zw,0)); // float3 tmpvar_31 =  ((DetailNormalMap.z * 2.0) - 1.0)，((DetailNormalMap.w * 2.0) - 1.0) ，0;

	//tbn * normal
	// float3x3 normalDirection = float3x3(i.tangentDir, i.bitangentDir, i.normalDir);
	float3 normalDirection = normalize((((normalize(tangentDir) * BaseNormal.x) + (normalize(bitangentDir) * BaseNormal.y)) + ( normalize(normaldir.xyz)* BaseNormal.z)));
	float3 finalNormal = normalize((BaseNormal.xyz + (( DetailNormal * 0.2) * (maokong_intensity * BaseNormal.w))));
	float3 normalDirection2 = normalize((((tangentDir * finalNormal.x)+(bitangentDir * finalNormal.y)) + (normaldir.xyz * finalNormal.z)));



	float3 tmpvar_34 = normalize(xlv_COLOR.xyz);

	float3 MaksNormalDir = normalize(((normalDirection2 * (1.0 - MaksTex.x)) + (tmpvar_34 * MaksTex.x)));

	float3 viewd = normalize(-(xlv_TEXCOORD3.xyz));

	


	float3 I_37 = -(viewd);

	float tmpvar_38 = clamp (dot (normalDirection, viewd), 0.0, 1.0);


	float SunCos = clamp (dot (normalDirection, LightDir), 0.0, 1.0);

	float F1_11 = (1.0 - tmpvar_38);
	F1_11 = (F1_11 * F1_11);

	float3 SpecularMask1_17 = (DetailNormalMap.x * _SkinSpec_color1);
	float3 SpecularMask2_16 = (DetailNormalMap.y * _SkinSpec_color2);

	SpecularMask1_17 = ((SpecularMask1_17 * (1.0 - F1_11)) + (0.5 * F1_11));
	SpecularMask2_16 = ((SpecularMask2_16 * (1.0 - F1_11)) + (0.5 * F1_11));

	float3 tmpvar_41 = (xlv_TEXCOORD7.xyz / xlv_TEXCOORD7.w);

	float tmpvar_42 = min (0.99999, tmpvar_41.z);

	

	float2 inRange_8 = float2(min (abs((tmpvar_41.xy - 0.5)), float2(0.5, 0.5)));

	inRange_8.x = (inRange_8.x * inRange_8.y);
	float inShadow_44;
	float4 Values3_45;
	float4 Values2_46;
	float4 Values1_47;
	float4 Values0_48;
	float2 tmpvar_49 = ((tmpvar_41.xy / cShadowBias.ww) - 0.5);

	//fract returns the fractional part of x. This is calculated as x - floor(x)  opengl call fract
	float2 tmpvar_50 = frac(tmpvar_49);
	float2 tmpvar_51;
	tmpvar_51 = ((floor(tmpvar_49) + 0.5) - float2(1.0, 1.0));
	Values0_48.x = dot (tex2D (sShadowMapSampler, (tmpvar_51 * cShadowBias.ww)), float4(1, 0, 1.5, 6));
	Values0_48.y = dot (tex2D (sShadowMapSampler, ((tmpvar_51 + float2(1.0, 0.0)) * cShadowBias.ww)), float4(1.0, 0, 1.5, 6));
	Values0_48.z = dot (tex2D (sShadowMapSampler, ((tmpvar_51 + float2(2.0, 0.0)) * cShadowBias.ww)), float4(1.0, 0, 1.5, 6));
	Values0_48.w = dot (tex2D (sShadowMapSampler, ((tmpvar_51 + float2(3.0, 0.0)) * cShadowBias.ww)), float4(1.0, 0, 1.5, 6));

	float4 tmpvar_52 = clamp ((((Values0_48 - float4(tmpvar_42,tmpvar_42,tmpvar_42,tmpvar_42))* 8000.0) + 1.0), 0.0, 1.0);


	Values0_48 = tmpvar_52;
	Values1_47.x = dot (tex2D (sShadowMapSampler, ((tmpvar_51 + float2(0.0, 1.0)) * cShadowBias.ww)), float4(1.0, 0.0, 1.5, 6.03));
	Values1_47.y = dot (tex2D (sShadowMapSampler, ((tmpvar_51 + float2(1.0, 1.0)) * cShadowBias.ww)), float4(1.0, 0.0, 1.5, 6.03));
	Values1_47.z = dot (tex2D (sShadowMapSampler, ((tmpvar_51 + float2(2.0, 1.0)) * cShadowBias.ww)), float4(1.0, 0.0, 1.5, 6.03));
	Values1_47.w = dot (tex2D (sShadowMapSampler, ((tmpvar_51 + float2(3.0, 1.0)) * cShadowBias.ww)), float4(1.0, 0.0, 1.5, 6.03));

	float4 tmpvar_53 = clamp ((((Values1_47 - float4(tmpvar_42,tmpvar_42,tmpvar_42,tmpvar_42))* 8000.0) + 1.0), 0.0, 1.0);
	Values1_47 = tmpvar_53;
	Values2_46.x = dot (tex2D (sShadowMapSampler, ((tmpvar_51 + float2(0.0, 2.0)) * cShadowBias.ww)), float4(1.0, 0.0, 1.5, 6.03));
	Values2_46.y = dot (tex2D (sShadowMapSampler, ((tmpvar_51 + float2(1.0, 2.0)) * cShadowBias.ww)), float4(1.0, 0.0, 1.5, 6.03));
	Values2_46.z = dot (tex2D (sShadowMapSampler, ((tmpvar_51 + float2(2.0, 2.0)) * cShadowBias.ww)), float4(1.0, 0.0, 1.5, 6.03));
	Values2_46.w = dot (tex2D (sShadowMapSampler, ((tmpvar_51 + float2(3.0, 2.0)) * cShadowBias.ww)), float4(1.0, 0.0, 1.5, 6.03));


	float4 tmpvar_54 = clamp (((
	(Values2_46 - float4(tmpvar_42,tmpvar_42,tmpvar_42,tmpvar_42))* 8000.0) + 1.0), 0.0, 1.0);
	Values2_46 = tmpvar_54;
	Values3_45.x = dot (tex2D (sShadowMapSampler, ((tmpvar_51 + float2(0.0, 3.0)) * cShadowBias.ww)), float4(1.0, 0.0, 1.5, 6.03));
	Values3_45.y = dot (tex2D (sShadowMapSampler, ((tmpvar_51 + float2(1.0, 3.0)) * cShadowBias.ww)), float4(1.0, 0.0, 1.5, 6.03));
	Values3_45.z = dot (tex2D (sShadowMapSampler, ((tmpvar_51 + float2(2.0, 3.0)) * cShadowBias.ww)), float4(1.0, 0.0, 1.5, 6.03));
	Values3_45.w = dot (tex2D (sShadowMapSampler, ((tmpvar_51 + float2(3.0, 3.0)) * cShadowBias.ww)), float4(1.0, 0.0, 1.5, 6.03));

	float4 tmpvar_55 = clamp ((((Values3_45 - float4(tmpvar_42,tmpvar_42,tmpvar_42,tmpvar_42))* 8000.0) + 1.0), 0.0, 1.0);
	Values3_45 = tmpvar_55;
	float2 tmpvar_56;
	tmpvar_56.x = tmpvar_52.x;
	tmpvar_56.y = tmpvar_53.x;
	float2 tmpvar_57;
	tmpvar_57.x = tmpvar_52.y;
	tmpvar_57.y = tmpvar_53.y;
	float2 tmpvar_58;
	tmpvar_58 = ((tmpvar_56 * (1.0 - tmpvar_50.xx)) + (tmpvar_57 * tmpvar_50.xx));
	float2 tmpvar_59;
	tmpvar_59.x = tmpvar_52.y;
	tmpvar_59.y = tmpvar_53.y;
	float2 tmpvar_60;
	tmpvar_60.x = tmpvar_52.z;
	tmpvar_60.y = tmpvar_53.z;
	float2 tmpvar_61;
	tmpvar_61 = ((tmpvar_59 * (1.0 - tmpvar_50.xx)) + (tmpvar_60 * tmpvar_50.xx));
	float2 tmpvar_62;
	tmpvar_62.x = tmpvar_52.z;
	tmpvar_62.y = tmpvar_53.z;
	float2 tmpvar_63;
	tmpvar_63.x = tmpvar_52.w;
	tmpvar_63.y = tmpvar_53.w;
	float2 tmpvar_64;
	tmpvar_64 = ((tmpvar_62 * (1.0 - tmpvar_50.xx)) + (tmpvar_63 * tmpvar_50.xx));
	float2 tmpvar_65;
	tmpvar_65.x = tmpvar_53.x;
	tmpvar_65.y = tmpvar_54.x;
	float2 tmpvar_66;
	tmpvar_66.x = tmpvar_53.y;
	tmpvar_66.y = tmpvar_54.y;
	float2 tmpvar_67;
	tmpvar_67 = ((tmpvar_65 * (1.0 - tmpvar_50.xx)) + (tmpvar_66 * tmpvar_50.xx));
	float2 tmpvar_68;
	tmpvar_68.x = tmpvar_53.y;
	tmpvar_68.y = tmpvar_54.y;
	float2 tmpvar_69;
	tmpvar_69.x = tmpvar_53.z;
	tmpvar_69.y = tmpvar_54.z;
	float2 tmpvar_70;
	tmpvar_70 = ((tmpvar_68 * (1.0 - tmpvar_50.xx)) + (tmpvar_69 * tmpvar_50.xx));
	float2 tmpvar_71;
	tmpvar_71.x = tmpvar_53.z;
	tmpvar_71.y = tmpvar_54.z;
	float2 tmpvar_72;
	tmpvar_72.x = tmpvar_53.w;
	tmpvar_72.y = tmpvar_54.w;
	float2 tmpvar_73;
	tmpvar_73 = ((tmpvar_71 * (1.0 - tmpvar_50.xx)) + (tmpvar_72 * tmpvar_50.xx));
	float2 tmpvar_74;
	tmpvar_74.x = tmpvar_54.x;
	tmpvar_74.y = tmpvar_55.x;
	float2 tmpvar_75;
	tmpvar_75.x = tmpvar_54.y;
	tmpvar_75.y = tmpvar_55.y;
	float2 tmpvar_76;
	tmpvar_76 = ((tmpvar_74 * (1.0 - tmpvar_50.xx)) + (tmpvar_75 * tmpvar_50.xx));
	float2 tmpvar_77;
	tmpvar_77.x = tmpvar_54.y;
	tmpvar_77.y = tmpvar_55.y;
	float2 tmpvar_78;
	tmpvar_78.x = tmpvar_54.z;
	tmpvar_78.y = tmpvar_55.z;
	float2 tmpvar_79;
	tmpvar_79 = ((tmpvar_77 * (1.0 - tmpvar_50.xx)) + (tmpvar_78 * tmpvar_50.xx));
	float2 tmpvar_80;
	tmpvar_80.x = tmpvar_54.z;
	tmpvar_80.y = tmpvar_55.z;
	float2 tmpvar_81;
	tmpvar_81.x = tmpvar_54.w;
	tmpvar_81.y = tmpvar_55.w;


	float2 tmpvar_82 = ((tmpvar_80 * (1.0 - tmpvar_50.xx)) + (tmpvar_81 * tmpvar_50.xx));
	inShadow_44 = (((((((((((tmpvar_58.x * (1.0 - tmpvar_50.y)) + (tmpvar_58.y * tmpvar_50.y)) + ((tmpvar_61.x * (1.0 - tmpvar_50.y))
	+ (tmpvar_61.y * tmpvar_50.y))) + ((tmpvar_64.x * (1.0 - tmpvar_50.y)) + (tmpvar_64.y * tmpvar_50.y)))
	+ ((tmpvar_67.x * (1.0 - tmpvar_50.y)) + (tmpvar_67.y * tmpvar_50.y))) + ((tmpvar_70.x * (1.0 - tmpvar_50.y))
	+ (tmpvar_70.y * tmpvar_50.y))) + ((tmpvar_73.x *  (1.0 - tmpvar_50.y)) + (tmpvar_73.y * tmpvar_50.y)))
	+ ((tmpvar_76.x * (1.0 - tmpvar_50.y)) + (tmpvar_76.y * tmpvar_50.y)))
	+ ((tmpvar_79.x * (1.0 - tmpvar_50.y)) + (tmpvar_79.y * tmpvar_50.y))) + ((tmpvar_82.x * (1.0 - tmpvar_50.y))
	+ (tmpvar_82.y * tmpvar_50.y))) * 0.11111);


	inShadow_44 = (1.0 - inShadow_44);
	inShadow_9 = (inShadow_44 * inRange_8.x);
	inShadow_9 = (1.0 - inShadow_9);
	shadow_10 = inShadow_9;


	float3 Shadow = ((SunColor * cPointCloud[0].w) * ShadowColor.y);




	float3 tmpvar_87 = (normalDirection * normalDirection);


	float3 tmpvar_88 = float3(min (normalDirection, float3(0.0, 0.0, 0.0)));


	float4 linearColor = (((tmpvar_87.x * cPointCloud[tmpvar_88.x]) + (tmpvar_87.y * cPointCloud[(tmpvar_88.y + 2)])) + (tmpvar_87.z * cPointCloud[(tmpvar_88.z + 4)]));



	float3 tmpvar_84 = (linearColor.xyz * (ShadowColor.x * (10.0 + ((cPointCloud[3].w * ShadowColor.z) * 100.0))));

	float3 tmpvar_90 = (tmpvar_84 * MaksTex.z);

	float3 VirtualLitDir = normalize(cVirtualLitDir.xyz);

	float3 ts =((0.444 + (0.556 * clamp (dot (MaksNormalDir, VirtualLitDir), 0.0, 1.0))));

	float3 tmpvar_92 = ((cVirtualLitColor * MaksTex.z) *ts);

	float tmpvar_93 = clamp ((0.6 + dot (tmpvar_34, LightDir)), 0.0, 1.0);


	float2 tmpvar_94;
	tmpvar_94.x = ((0.5 * dot (normalDirection, LightDir)) + 0.5);
	tmpvar_94.y = (cSSSIntensity * MaksTex.y);


	float4 LutMapSampler = tex2D (sLutMapSampler, tmpvar_94);

	float tmpvar_96 = (shadow_10 + ((clamp (dot (normalDirection2, LightDir), 0.0, 1.0)- SunCos) * shadow_10));



	float SSSIntensity = (1.0 - cSSSIntensity);

	float3 tmpvar_97;

	tmpvar_97.x = ((sqrt((tmpvar_96 + 0.0001)) * (1.0 - SSSIntensity)) + (tmpvar_96 * SSSIntensity));

	tmpvar_97.yz = float2(tmpvar_96,tmpvar_96);

	DiffuseIrradiance_7 = (((tmpvar_90 + ((((((Shadow + tmpvar_90) * MaksTex.x)* cSSSColor.xyz) * float3(tmpvar_93,tmpvar_93,tmpvar_93)) * float3(tmpvar_93,tmpvar_93,tmpvar_93)) * shadow_10)
	) + tmpvar_92) + (((((tmpvar_97 * tmpvar_97) * (LutMapSampler.xyz * LutMapSampler.xyz)) * (1.0 - Ma))+ ((SunCos * shadow_10) * Ma)
	) * Shadow));



	float tmpvar_99 = (((1.0 - ((1.0 - Roughness_18) * RoughnessOffset1)) * (1.0 - Ma)) + (Roughness_18 * Ma));

	float tmpvar_100 = (((Roughness_18 * RoughnessOffset2) * (1.0 - Ma)) + (Roughness_18 * Ma));
	float d_101;
	float m2_102;
	float m_103;
	float3 tmpvar_104;
	tmpvar_104 = normalize((LightDir + viewd));
	float tmpvar_105;
	tmpvar_105 = clamp (dot (normalDirection2, tmpvar_104), 0.0, 1.0);
	float tmpvar_106;
	tmpvar_106 = clamp (dot (viewd, tmpvar_104), 0.0, 1.0);
	float tmpvar_107;
	tmpvar_107 = (tmpvar_99 * tmpvar_99);
	float tmpvar_108;
	tmpvar_108 = (tmpvar_107 * tmpvar_107);
	float tmpvar_109;
	tmpvar_109 = (((
	(tmpvar_105 * tmpvar_108)
	- tmpvar_105) * tmpvar_105) + 1.0);
	m_103 = (tmpvar_100 * tmpvar_100);
	m2_102 = (m_103 * m_103);
	d_101 = (((
	(tmpvar_105 * m2_102)
	- tmpvar_105) * tmpvar_105) + 1.0);
	float3 tmpvar_110;
	tmpvar_110 = ((float3(0.04, 0.04, 0.04) + (float3(0.96, 0.96, 0.96) * 
	exp2((((-5.55473 * tmpvar_106) - 6.98316) * tmpvar_106))
	)) * 0.25);
	float tmpvar_111;
	tmpvar_111 = ((Shadow * SunCos) * (2.0 * shadow_10)).x;
	float tmpvar_112;
	tmpvar_112 = (((tmpvar_108 / 
	((tmpvar_109 * tmpvar_109) * 3.141593)
	) * tmpvar_110) * tmpvar_111).x;
	float3 BRDF1_113;
	float d_114;
	float m2_115;
	float m_116;
	float3 tmpvar_117;
	tmpvar_117 = normalize((VirtualLitDir + viewd));
	float tmpvar_118;
	tmpvar_118 = clamp (dot (normalDirection2, tmpvar_117), 0.0, 1.0);

	float tmpvar_119 = clamp (dot (viewd, tmpvar_117), 0.0, 1.0);

	float tmpvar_120 = (tmpvar_99 * tmpvar_99);
	float tmpvar_121;
	tmpvar_121 = (tmpvar_120 * tmpvar_120);
	float tmpvar_122;
	tmpvar_122 = ((((tmpvar_118 * tmpvar_121)- tmpvar_118) * tmpvar_118) + 1.0);

	m_116 = (tmpvar_100 * tmpvar_100);
	m2_115 = (m_116 * m_116);
	d_114 = ((((tmpvar_118 * m2_115)- tmpvar_118) * tmpvar_118) + 1.0);


	float3 tmpvar_123;
	tmpvar_123 = ((float3(0.04, 0.04, 0.04) + (float3(0.96, 0.96, 0.96) * exp2((((-5.55473 * tmpvar_119) - 6.98316) * tmpvar_119)))) * 0.25);
	BRDF1_113 = ((tmpvar_121 / (
	(tmpvar_122 * tmpvar_122)
	* 3.141593)) * tmpvar_123);
	float3 tmpvar_124;
	float Roughness_125;
	Roughness_125 = Roughness_18;
	float4 tmpvar_126;
	tmpvar_126 = ((Roughness_125 * float4(-1.0, -0.0275, -0.572, 0.022)) + float4(1.0, 0.0425, 1.04, -0.04));
	float2 tmpvar_127;
	tmpvar_127 = ((float2(-1.04, 1.04) * (
	(min ((tmpvar_126.x * tmpvar_126.x), exp2((-9.28 * tmpvar_38))) * tmpvar_126.x)
	+ tmpvar_126.y)) + tmpvar_126.zw);
	tmpvar_124 = ((float3(0.04, 0.04, 0.04) * tmpvar_127.x) + tmpvar_127.y);
	float Roughness_128;
	Roughness_128 = tmpvar_100;

	float3 R_129 = (I_37 - (2.0 * (dot (normalDirection, I_37)* normalDirection)));


	float tmpvar_134 = float((R_129.z > 0.0));

	float tmpvar_135 = ((tmpvar_134 * 2.0) - 1.0);
	R_129.xy = (R_129.xy / ((R_129.z * tmpvar_135) + 1.0));
	R_129.xy = ((R_129.xy * float2(0.25, -0.25)) + (0.25 + (0.5 * tmpvar_134)));


	float4 IBL = texCUBElod(sEnvSampler,float4(R_129, (Roughness_128 / 0.17))).xyzw;

	float3 SPL = (IBL.xyz * ((IBL.w * IBL.w) * 16.0));

	SPL = (SPL * ((cEnvStrength * EnvInfo.w) * 10.0));



	SpecRadiance_6 = (((((tmpvar_112 * SpecularMask1_17) + ((tmpvar_111 * ( (m2_102 / ((d_101 * d_101) * 3.141593))* tmpvar_110)) * SpecularMask2_16))* (1.0 - Ma)
	) + ((tmpvar_112 * 0.5)* Ma)) + (((tmpvar_92 * ((BRDF1_113 * SpecularMask1_17) + ((
	(m2_115 / ((d_114 * d_114) * 3.141593))* tmpvar_123) * SpecularMask2_16)))* (1.0 - Ma)) + ((tmpvar_92 * BRDF1_113)* Ma)));
	SpecRadiance_6 = (SpecRadiance_6 + (((((tmpvar_124 * tmpvar_90) * (SpecularMask1_17 * EnvInfo.w)) * (5.0 * cEnvStrength))* 
	(1.0 - Ma)) + ((((SPL * tmpvar_124) * MaksTex.z) * ((SpecularMask2_16 * (1.0 - Ma)) + Ma))* dot (tmpvar_90, float3(0.3, 0.59, 0.11)))));



	float tmpvar_137 = (((SpecularMask2_16 + SpecularMask1_17) * (1.0 - Ma)) + Ma).x;

	specularMask_5 = tmpvar_137;



	float3 SpecularColor = (float3(0.04, 0.04, 0.04) * specularMask_5);


	float Roughness_var = clamp (Roughness_18, 0.0, 1.0);


	float3 DiffLit_141 = DiffuseIrradiance_7;

	float3 lighting_142 = float3(0.0, 0.0, 0.0);;



	if ((Lights0[3].w > 0.0)) {

	float D_143;
	float m2_144;
	
	float3 L_146;
	


	float3 LightDis = (Lights0[0].xyz - posWorld.xyz);

	float RealDis = sqrt(dot (LightDis, LightDis));
	L_146 = (LightDis / RealDis);
	float tmpvar_149;
	tmpvar_149 = clamp (dot (MaksNormalDir, L_146), 0.0, 1.0);
	
	float Atten = clamp (((RealDis * Lights0[1].w) + Lights0[0].w), 0.0, 1.0);

	Atten = (Atten * Atten);

	DiffLit_141 = (DiffLit_141 + (Lights0[1].xyz * (tmpvar_149 * Atten)));

	
	float tmpvar_151 = ((Roughness_var * Roughness_var) + 0.0002);
	m2_144 = tmpvar_151;
	m2_144 = (m2_144 * m2_144);
	float tmpvar_152;
	tmpvar_152 = clamp (dot (MaksNormalDir, normalize(
	(viewd + L_146)
	)), 0.0, 1.0);
	float tmpvar_153;
	tmpvar_153 = (((
	(tmpvar_152 * m2_144)
	- tmpvar_152) * tmpvar_152) + 1.0);
	D_143 = ((tmpvar_153 * tmpvar_153) + 1e-06);
	D_143 = ((0.25 * m2_144) / D_143);

	lighting_142 = ((Lights0[1].xyz * SpecularColor) * ((Atten * tmpvar_149) * D_143));

	};

/////spot Light
	if (((Lights1[3].w > 0.0) && (Lights1[2].w <= 0.0))) {

	float D_154;
	float m2_155;
	
	float4 Light0 = Lights1[0];
	float4 Light1 = Lights1[1];
	float3 Light2 = Lights1[3].xyz;


	//light2obj position
	float3 LightDis = (Light0.xyz - posWorld.xyz);

	float RealDis = sqrt(dot (LightDis, LightDis));

	LightDis = (LightDis / RealDis);

	float PointlightCos = clamp (dot (MaksNormalDir, LightDis), 0.0, 1.0);

	float tmpvar_167 = dot (Lights1[2].xyz, -(LightDis));

	float Atten = clamp (((RealDis * Light1.w) + Light0.w), 0.0, 1.0);

	Atten = (Atten * Atten);

	
	float spot = pow (clamp (((tmpvar_167 * Light2.y) + Light2.z), 0.0, 1.0), Light2.x);

	
	float tmpvar_171;
	tmpvar_171 = ((Roughness_var * Roughness_var) + 0.0002);
	m2_155 = tmpvar_171;
	m2_155 = (m2_155 * m2_155);

	float tmpvar_172 = clamp (dot (MaksNormalDir, normalize((viewd + LightDis))), 0.0, 1.0);


	float tmpvar_173 = ((((tmpvar_172 * m2_155)- tmpvar_172) * tmpvar_172) + 1.0);

	D_154 = ((tmpvar_173 * tmpvar_173) + 1e-06);

	D_154 = ((0.25 * m2_155) / D_154);

	lighting_142 = (lighting_142 + (((Lights1[1].xyz * SpecularColor)* ((Atten * PointlightCos) * D_154)) * spot));

	DiffLit_141 = (DiffLit_141 + (Light1.xyz * ((PointlightCos * Atten)* spot)));
	};


	DiffuseIrradiance_7 = DiffLit_141;
	SpecRadiance_6 = (SpecRadiance_6 + lighting_142);

	float3 Cubeconver = (SpecRadiance_6 + ((DiffuseIrradiance_7 * BaseColor.xyz) / 3.141593));



/////emission use for mask face mask additve
	////Emssion Mask
	float4 EmssionMap = tex2D (sEmissionSampler, uv0);
    // float tmpvar_178 = clamp ((sin(((6.283185 * (CameraPosPS.w - EmssionColor.w)) * EmssionColor.z)) - 0.8), 0.0, 1.0);
    //float3 finalEmssion = (EmssionMap.xyz * (EmssionMap.w * ((EmssionColor.x * (1.0 - tmpvar_178)) + (EmssionColor.y * tmpvar_178))));
	float EmissionMask = 1 -clamp ((sin(((6.283185 *(CameraPosPS - EmssionColor.w)) * EmssionColor.z)) - 0.8), 0.0, 1.0);
	float3 finalEmssion = EmissionMask * EmssionMap * EmssionMap.w ;

    

	float3 Diff = (Cubeconver.xyz + finalEmssion);

	return float4(Diff,1);

	float3 fogColor_2 = ((FogColor2 * clamp (((viewd.y * 5.0) + 1.0), 0.0, 1.0)) + FogColor.xyz);

	float VoL_1 = clamp (dot (-(viewd), LightDir), 0.0, 1.0);

	fogColor_2 = (fogColor_2 + (FogColor3 * (VoL_1 * VoL_1)).xyz);

	float tmpvar_181;

	tmpvar_181 = (1.0 - xlv_TEXCOORD3.w);

	Diff = ((Diff* tmpvar_181) + (((Diff * tmpvar_181) + fogColor_2) * xlv_TEXCOORD3.w));

	Diff = (Diff * EnvInfo.z);

	Diff = clamp (Diff, float3(0.0, 0.0, 0.0), float3(4.0, 4.0, 4.0));

	float3 FinalFog = ( FogColor.w ,FogColor2.w ,FogColor3.w);

	Diff.xyz = (Diff * FinalFog);

	Diff.xyz = (Diff / ((Diff * 0.9661836) + 0.180676));				
	return fixed4(Diff,1);
	}
	ENDCG
	}
	}
	   // CustomEditor "CharShaderEditor"
    FallBack "Diffuse"
}
