﻿Shader "Unlit/chuliuxiang"
{
	Properties
	{
		sBaseSampler ("sBaseSampler", 2D) = "white" {}
		sMixSampler ("sMixSampler", 2D) = "white" {}
		sNormalSampler ("sNormalSampler", 2D) = "white" {}
		sDetailNormalSampler ("sDetailNormalSampler", 2D) = "white" {}
		sLutMapSampler ("sLutMapSampler", 2D) = "white" {}
		sEnvSampler ("sEnvSampler", 2D) = "white" {}
		sShadowMapSampler ("sShadowMapSampler", 2D) = "white" {}
		sEmissionSampler ("sEmissionSampler", 2D) = "white" {}
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
			#pragma glsl

			sampler2D _MainTex;
			float4 _MainTex_ST;

			//v
			uniform float4x4 ViewProjVS;
			uniform float4 CameraPosVS;
			uniform float4x4 LightViewProjTex;
			uniform float4 FogInfo;
			uniform float4 SkeletonData[192];
			uniform float4x4 World;

			//f

			uniform float4 CameraPosPS;
			uniform float4 EnvInfo;
			uniform float4 SunColor;
			uniform float4 SunDirection;
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

			uniform float4 cEmissionScale;
			uniform float4 _SkinSpec_color1;
			uniform float4 _SkinSpec_color2;
			uniform float4 cSSSColor;

			uniform sampler2D sBaseSampler;
			uniform sampler2D sMixSampler;
			uniform sampler2D sNormalSampler;
			uniform sampler2D sDetailNormalSampler;
			uniform sampler2D sLutMapSampler;
			uniform samplerCUBE sEnvSampler;
			uniform sampler2D sShadowMapSampler;
			uniform sampler2D sEmissionSampler;



       



			struct vertexin
			{
				float4 position : POSITION;
				float4 normal: NORMAL;
				float4 tangent: TANGENT;
				float2 uv : TEXCOORD0;				
				float2 texcoord0: TEXCOORD0;
				float2 texcoord2: TEXCOORD2;
				float4 color:COLOR;
			
			//	in  float4 POSITION;
			//	in  float4 COLOR;
			
			//	in  float2 TEXCOORD0;			
			//	in  float4 BINORMAL;
			//	in  float4 BLENDWEIGHT;
			//	in   float4 BLENDINDICES;
				
			};

			struct vertexout
			{
				//float2 uv : TEXCOORD0;
			
				float4 Position : SV_POSITION;
			
				float2 uv0:TEXCOORD0;//TEXCOORD0	
				float4 xlv_TEXCOORD1:TEXCOORD1;	
				float3 normaldir:TEXCOORD2;//float2 TEXCOORD2:TEXCOORD2;	
				float4 xlv_TEXCOORD3:TEXCOORD3; 
				float3 tangentDir:TEXCOORD4; //	float2 TEXCOORD4:TEXCOORD4;	
				float3 bitangentDir:TEXCOORD5;//float2 TEXCOORD5:xlv_TEXCOORD5
				
				float4 xlv_COLOR:Color;
				float4 xlv_TEXCOORD7:TEXCOORD7;
									
			};

			
			vertexout vert (vertexin v)
			{
				vertexout o;

				float4 vertex= (v.position.xyz,1);
				// 将法线向量转换为范围[-1,1] //normal
				float3 tmpvar_1 = (v.normal.xyz * 2.0) - 1.0;

				float3 tmpvar_3 = normalize(v.tangent.xyz);

				float3 tmpvar_4 = cross(tmpvar_1,tmpvar_3);


			

				float4 BLENDINDICES;
				float4 BLENDWEIGHT;

				float4 tmpvar_7 = BLENDINDICES;


				int idx_8 = tmpvar_7.x;
				int idx_9 = tmpvar_7.y;
				int idx_10 = tmpvar_7.z;
				int idx_11 = tmpvar_7.w;

				float4 BoneVertex1  = ((((BLENDWEIGHT.x * SkeletonData[(3 * idx_8)])
					                           + (BLENDWEIGHT.y * SkeletonData[(3 * idx_9)])) 
				                               + (BLENDWEIGHT.z * SkeletonData[(3 * idx_10)])) 
				                               + (BLENDWEIGHT.w * SkeletonData[(3 * idx_11)]));

				 float4 BoneVertex2  = ((((BLENDWEIGHT.x * SkeletonData[((3 * idx_8) + 1)])
				 	                             + (BLENDWEIGHT.y * SkeletonData[((3 * idx_9) + 1)])) 
				                                  + (BLENDWEIGHT.z * SkeletonData[((3 * idx_10) + 1)])) 
				                                  + (BLENDWEIGHT.w * SkeletonData[((3 * idx_11)+ 1)]));

				 float4 BoneVertex3 = ((((BLENDWEIGHT.x * SkeletonData[((3 * idx_8) + 2)]) 
				 	                 + (BLENDWEIGHT.y * SkeletonData[((3 * idx_9) + 2)]))
				 	                 + (BLENDWEIGHT.z * SkeletonData[((3 * idx_10) + 2)])) 
				                     + (BLENDWEIGHT.w * SkeletonData[((3 * idx_11)+ 2)]));

////bonevertexspace
   float3 BoneVertexSpace = (dot (BoneVertex1.xyz, vertex.xyz), dot (BoneVertex2.xyz, vertex.xyz) ,dot (BoneVertex3.xyz, vertex.xyz));

 
   float3 BonePosition = (BoneVertex1.w,BoneVertex2.w,BoneVertex3.w);

   float4 NewBonePositon1 = ((BoneVertexSpace + BonePosition), vertex.w);



   float3 tmpvar_17 = (dot (BoneVertex1.xyz, tmpvar_1) ,dot (BoneVertex2.xyz, tmpvar_1) , dot (BoneVertex3.xyz, tmpvar_1));
 
   float3 tmpvar_18 = ( dot (BoneVertex1.xyz, tmpvar_3),dot (BoneVertex2.xyz, tmpvar_3)  ,dot (BoneVertex3.xyz, tmpvar_3));
  
   float3 tmpvar_19 = (dot (BoneVertex1.xyz, tmpvar_4), dot (BoneVertex2.xyz, tmpvar_4) , dot (BoneVertex3.xyz, tmpvar_4));

 
  float3 tmpvar_6 = ((v.color.zyx * 2.0) - 1.0);

   float3 tmpvar_20 = ( -(tmpvar_6.x) ,tmpvar_6.z , tmpvar_6.y );

   float3 tmpvar_21 = (dot (BoneVertex1.xyz, tmpvar_20) , dot (BoneVertex2.xyz, tmpvar_20) ,dot (BoneVertex3.xyz, tmpvar_20));

  tmpvar_6 = tmpvar_21;

   float4 tmpvar_22;
   float4 tmpvar_23;
   float4 tmpvar_24;

   float4 tmpvar_25;

   float4 tmpvar_27 = (mul(World,NewBonePositon1).xyz,1);

   float3x3 tmpvar_28 ={
   	                    World[0].xyz,
   	                    World[1].xyz,
   	                    World[2].xyz
   	                   };


   tmpvar_22.xyz = normalize(mul(tmpvar_28,tmpvar_17));



  float3x3 tmpvar_29 = 
  {
   World[0].xyz,
   World[1].xyz, 
   World[2].xyz
  };



   float3x3 tmpvar_30;
  tmpvar_30[0] = World[0].xyz;
  tmpvar_30[1] = World[1].xyz;
  tmpvar_30[2] = World[2].xyz;
   float3x3 tmpvar_31;
  tmpvar_31[0] = World[0].xyz;
  tmpvar_31[1] = World[1].xyz;
  tmpvar_31[2] = World[2].xyz;

  tmpvar_25.xyz = normalize(mul( tmpvar_31,tmpvar_21));


  tmpvar_23.xyz = (tmpvar_27.xyz - CameraPosVS.xyz);
  
   float tmpvar_33  = clamp (((tmpvar_27.y * FogInfo.z) + FogInfo.w), 0.0, 1.0); 
  
 float  fHeightCoef_32 = (tmpvar_33 * tmpvar_33);

  fHeightCoef_32 = (fHeightCoef_32 * fHeightCoef_32);

   float tmpvar_34 = (1.0 - exp((
    -(max (0.0, (sqrt(
      dot (tmpvar_23.xyz, tmpvar_23.xyz)
    ) - FogInfo.x)))
   * 
    max ((FogInfo.y * fHeightCoef_32), (0.1 * FogInfo.y))
  )));




  tmpvar_23.w = (tmpvar_34 * tmpvar_34);
  tmpvar_24.xyz = float3(0.0, 0.0, 0.0);
  tmpvar_24.w = 0.0;
   float4 tmpvar_35;
   float4 tmpvar_36;
  tmpvar_36.xyz = tmpvar_22.xyz;
  tmpvar_36.w = 0.0;

  float4 tmpvar_37 = (tmpvar_27.xyz,1);



  tmpvar_35 =mul( ViewProjVS,tmpvar_37);


  tmpvar_22 = tmpvar_36;

 
  v.position.xyz = tmpvar_35.xyw;  //gl_Position.xyw = tmpvar_35.xyw;

 
  	o.uv0 = v.texcoord0; //xlv_TEXCOORD0 = TEXCOORD0.xyxy;

  xlv_TEXCOORD1 = tmpvar_27;
  xlv_TEXCOORD2 = tmpvar_36;
  xlv_TEXCOORD3 = tmpvar_23;
  xlv_TEXCOORD4 = normalize(clamp ((tmpvar_18 * tmpvar_29), -2.0, 2.0));
  xlv_TEXCOORD5 = normalize(clamp ((tmpvar_19 * tmpvar_30), -2.0, 2.0));
  xlv_TEXCOORD6 = tmpvar_24;


  xlv_TEXCOORD7 = (tmpvar_27 * LightViewProjTex);


  xlv_COLOR = tmpvar_25;


  gl_Position.z = ((tmpvar_35.z * 2.0) - tmpvar_35.w);










			

				o.normaldir = v.normal;

				o.tangentDir = v.tangent;

				o.xlv_TEXCOORD3;
				o.xlv_TEXCOORD7;
				o.xlv_TEXCOORD1;




				
				

				tmpvar_1 = (v.normal.xyz * 2) -1 ; 
				tmpvar_3 = normalize(v.tangent.xyz);
				//tmpvar_4 = normalize(v.binormal.xyz);
				float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 binormal = cross(normalize(worldNormal), normalize(worldTangent)) * v.tangent.w;
				o.Position = UnityObjectToClipPos(v.position);

                //世界空间法线
				//o.normalDir = UnityObjectToWorldNormal(v.normal);
				//世界空间切线
                //o.tangentDir = normalize(mul(unity_ObjectToWorld, float4(v.tangent.xyz, 0.0)).xyz);
                //世界空间副切线
               // o.bitangentDir = normalize(cross(o.normalDir, o.tangentDir) * v.tangent.w);
			//	o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				float4 tmpvar_25;

				//tmpvar_25.xyz = normalize()

				//o.xlv_COLOR = ;

//				o.Position =  ((tmpvar_35.z * 2.0) - tmpvar_35.w);
				
				return o;
			}
			
			fixed4 frag (vertexout i) : SV_Target
			{
				float2 uv0 = i.uv0;
				float3 normaldir = i.normaldir;
				float3 tangentDir = i.tangentDir;
				float3 bitangentDir = i.bitangentDir;
				float4 xlv_COLOR = i.xlv_COLOR;
				float4 xlv_TEXCOORD3 = i.xlv_TEXCOORD3;
				float4 xlv_TEXCOORD7 = i.xlv_TEXCOORD7;
				float4 xlv_TEXCOORD1 = i.xlv_TEXCOORD1;

				float VoL_1;
				float3 fogColor_2;
				float4 emission_3;
				float4 OUT_4;
				float specularMask_5;
				float3 SpecRadiance_6;
				float3 DiffuseIrradiance_7;
				float2 inRange_8;
				float inShadow_9;
				float shadow_10;
				float F1_11;
				float NoL_12;
				float NoV_13;
	
				float vertexColorW_15;
				float3 SpecularMask2_16;
				float3 SpecularMask1_17;
				float Roughness_18;
				
				

////basecolor
				float4 Basesampler_var = tex2Dbias (sBaseSampler, float4(uv0.xy,0,cBaseMapBias));
				float4 BaseColor = ( Basesampler_var.rgb * Basesampler_var.rgb , Basesampler_var.a);     				
				float Roughness_21 =  max ((1.0 - Basesampler_var.w), 0.03);

			
				float tmpvar_23 = (EnvInfo.x * 0.5);

				float rain_22 = tmpvar_23;

				float tmpvar_24 = clamp ((((3.0 * normaldir.y)+ 0.2) + (0.1 * rain_22)), 0.0, 1.0);

				rain_22 = (1.0 - (rain_22 * tmpvar_24));

				
				 float tmpvar_25 = clamp ((rain_22 * Roughness_21), 0.05, 1.0);

				 Roughness_18 = tmpvar_25;

				float4 tmpvar_26 = tex2D (sMixSampler, uv0.xy);

				BaseColor.xyz = ((BaseColor.xyz * (1.0 - tmpvar_26.w)) + ((BaseColor.xyz * float3(1.35, 1.2, 1.3)) * tmpvar_26.w));		
				float tmpvar_27 = (1.0 - tmpvar_26.w);
				vertexColorW_15 = tmpvar_27;

////Normal mapping

               float4 Normalmap =  tex2Dbias (sNormalSampler, float4 (uv0.xy,0, cNormalMapBias));
               float4 tangentNormal = Normalmap;
               tangentNormal.xyz = UnpackNormal(tangentNormal);
               // 将法线向量转换为范围[-1,1]
              // tangentNormal.xyz = ((tangentNormal.xyz * 2.0) - 1.0);

              
               //tbn * normal
               float3 tmpvar_29 = normalize((((normalize(tangentDir) * tangentNormal.x) + (normalize(bitangentDir) * tangentNormal.y)) + ( normalize(normaldir.xyz)* tangentNormal.z)));

               float4 DetailNormalMap = tex2D (sDetailNormalSampler, (uv0.xy * cDetailUVScale));
            
          
               // 将法线向量转换为范围[-1,1]
               float3 tmpvar_31 = UnpackNormal(DetailNormalMap); // float3 tmpvar_31 =  ((DetailNormalMap.z * 2.0) - 1.0)，((DetailNormalMap.w * 2.0) - 1.0) ，0;

               float3 newnormal = normalize((tangentNormal.xyz + ((tmpvar_31 * 0.2) * (maokong_intensity * tangentNormal.w))));

               float3 tmpvar_33 = normalize((((tangentDir * newnormal.x)+(bitangentDir * newnormal.y)) + (normaldir.xyz * newnormal.z)));

               SpecularMask1_17 = (DetailNormalMap.xxx * _SkinSpec_color1.xyz);
               SpecularMask2_16 = (DetailNormalMap.yyy * _SkinSpec_color2.xyz);

               float3 tmpvar_34 = normalize(xlv_COLOR.xyz);
               float3 tmpvar_35 = normalize(((tmpvar_33 * (1.0 - tmpvar_26.x)) + (tmpvar_34 * tmpvar_26.x)));
               float3 tmpvar_36 = normalize(-(xlv_TEXCOORD3.xyz));

				float3 I_37 = -(tmpvar_36);
				float tmpvar_38 = clamp (dot (tmpvar_29, tmpvar_36), 0.0, 1.0);
				NoV_13 = tmpvar_38;
				float tmpvar_39 = clamp (dot (tmpvar_29, SunDirection.xyz), 0.0, 1.0);
				NoL_12 = tmpvar_39;

				float tmpvar_40 = (1.0 - NoV_13);
				F1_11 = tmpvar_40;
				F1_11 = (F1_11 * F1_11);
				SpecularMask1_17 = ((SpecularMask1_17 * (1.0 - F1_11)) + (0.5 * F1_11));
				SpecularMask2_16 = ((SpecularMask2_16 * (1.0 - F1_11)) + (0.5 * F1_11));
  
				float3 tmpvar_41 = (xlv_TEXCOORD7.xyz / xlv_TEXCOORD7.w);
				float tmpvar_42 = min (0.99999, tmpvar_41.z);
				float2 tmpvar_43 = float2(min (abs((tmpvar_41.xy - 0.5)), float2(0.5, 0.5)));
				inRange_8 = tmpvar_43;
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

  
  float3 tmpvar_83 = ((SunColor.xyz * cPointCloud[0].w) * ShadowColor.y);

   float3 tmpvar_84;
   float4 linearColor_85;
  

  float3 tmpvar_87 = (tmpvar_29 * tmpvar_29);
  float3 nSquared_86 = tmpvar_87;




   half3 tmpvar_88;
  tmpvar_88 = half3(min (tmpvar_29, float3(0.0, 0.0, 0.0)));
   float4 tmpvar_89;
  tmpvar_89 = (((nSquared_86.x * cPointCloud[tmpvar_88.x]) + (nSquared_86.y * cPointCloud[
    (tmpvar_88.y + 2)
  ])) + (nSquared_86.z * cPointCloud[(tmpvar_88.z + 4)]));
  linearColor_85 = tmpvar_89;
  tmpvar_84 = (linearColor_85.xyz * (ShadowColor.x * (10.0 + 
    ((cPointCloud[3].w * ShadowColor.z) * 100.0)
  )));
   float3 tmpvar_90;
  tmpvar_90 = (tmpvar_84 * tmpvar_26.z);
   float3 tmpvar_91;
  tmpvar_91 = normalize(cVirtualLitDir.xyz);

 float3 ts =((0.444 + (0.556 * clamp (dot (tmpvar_35, tmpvar_91), 0.0, 1.0))));

  float3 tmpvar_92 = ((cVirtualLitColor * tmpvar_26.z) *ts);
  
 float tmpvar_93 = clamp ((0.6 + dot (tmpvar_34, SunDirection.xyz)), 0.0, 1.0);


   float2 tmpvar_94;
  tmpvar_94.x = ((0.5 * dot (tmpvar_29, SunDirection.xyz)) + 0.5);
  tmpvar_94.y = (cSSSIntensity * tmpvar_26.y);
  




  float4 tmpvar_95 = tex2D (sLutMapSampler, tmpvar_94);




   float tmpvar_96;
  tmpvar_96 = (shadow_10 + ((clamp (dot (tmpvar_33, SunDirection.xyz), 0.0, 1.0)- NoL_12) * shadow_10));

   float3 tmpvar_97;
  
  float tmpvar_98 = (1.0 - cSSSIntensity);

  tmpvar_97.x = ((sqrt((tmpvar_96 + 0.0001)) * (1.0 - tmpvar_98)) + (tmpvar_96 * tmpvar_98));



  tmpvar_97.yz = float2(tmpvar_96,tmpvar_96);

  DiffuseIrradiance_7 = (((tmpvar_90 + ((((((tmpvar_83 + tmpvar_90) * tmpvar_26.x)* cSSSColor.xyz) * float3(tmpvar_93,tmpvar_93,tmpvar_93)) * float3(tmpvar_93,tmpvar_93,tmpvar_93)) * shadow_10)
  ) + tmpvar_92) + (((((tmpvar_97 * tmpvar_97) * (tmpvar_95.xyz * tmpvar_95.xyz)) * (1.0 - vertexColorW_15))+ ((NoL_12 * shadow_10) * vertexColorW_15)
  ) * tmpvar_83));


   float tmpvar_99;
  tmpvar_99 = (((1.0 - 
    ((1.0 - Roughness_18) * RoughnessOffset1)
  ) * (1.0 - vertexColorW_15)) + (Roughness_18 * vertexColorW_15));
   float tmpvar_100;
  tmpvar_100 = (((Roughness_18 * RoughnessOffset2) * (1.0 - vertexColorW_15)) + (Roughness_18 * vertexColorW_15));
   float d_101;
   float m2_102;
   float m_103;
   float3 tmpvar_104;
  tmpvar_104 = normalize((SunDirection.xyz + tmpvar_36));
   float tmpvar_105;
  tmpvar_105 = clamp (dot (tmpvar_33, tmpvar_104), 0.0, 1.0);
   float tmpvar_106;
  tmpvar_106 = clamp (dot (tmpvar_36, tmpvar_104), 0.0, 1.0);
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
  tmpvar_111 = ((tmpvar_83 * NoL_12) * (2.0 * shadow_10)).x;
   float tmpvar_112;
  tmpvar_112 = (((tmpvar_108 / 
    ((tmpvar_109 * tmpvar_109) * 3.141593)
  ) * tmpvar_110) * tmpvar_111).x;
   float3 BRDF1_113;
   float d_114;
   float m2_115;
   float m_116;
   float3 tmpvar_117;
  tmpvar_117 = normalize((tmpvar_91 + tmpvar_36));
   float tmpvar_118;
  tmpvar_118 = clamp (dot (tmpvar_33, tmpvar_117), 0.0, 1.0);
   float tmpvar_119;
  tmpvar_119 = clamp (dot (tmpvar_36, tmpvar_117), 0.0, 1.0);
   float tmpvar_120;
  tmpvar_120 = (tmpvar_99 * tmpvar_99);
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
    (min ((tmpvar_126.x * tmpvar_126.x), exp2((-9.28 * NoV_13))) * tmpvar_126.x)
   + tmpvar_126.y)) + tmpvar_126.zw);
  tmpvar_124 = ((float3(0.04, 0.04, 0.04) * tmpvar_127.x) + tmpvar_127.y);
   float Roughness_128;
  Roughness_128 = tmpvar_100;
   float3 R_129;
  R_129 = (I_37 - (2.0 * (
    dot (tmpvar_29, I_37)
   * tmpvar_29)));
   float4 srcColor_130;
   float fSign_131;
   float3 sampleEnvSpecular_132;
   float tmpvar_133;
  tmpvar_133 = (Roughness_128 / 0.17);
   float tmpvar_134;
  tmpvar_134 = float((R_129.z > 0.0));
  fSign_131 = tmpvar_134;
   float tmpvar_135;
  tmpvar_135 = ((fSign_131 * 2.0) - 1.0);
  R_129.xy = (R_129.xy / ((R_129.z * tmpvar_135) + 1.0));
  R_129.xy = ((R_129.xy * float2(0.25, -0.25)) + (0.25 + (0.5 * fSign_131)));



  float4 tmpvar_136 = texCUBElod(sEnvSampler,float4(R_129, tmpvar_133)).xyzw;




  srcColor_130 = tmpvar_136;

  sampleEnvSpecular_132 = (srcColor_130.xyz * ((srcColor_130.w * srcColor_130.w) * 16.0));
  sampleEnvSpecular_132 = (sampleEnvSpecular_132 * ((cEnvStrength * EnvInfo.w) * 10.0));


  SpecRadiance_6 = (((
    ((tmpvar_112 * SpecularMask1_17) + ((tmpvar_111 * (
      (m2_102 / ((d_101 * d_101) * 3.141593))
     * tmpvar_110)) * SpecularMask2_16))
   * 
    (1.0 - vertexColorW_15)
  ) + (
    (tmpvar_112 * 0.5)
   * vertexColorW_15)) + ((
    (tmpvar_92 * ((BRDF1_113 * SpecularMask1_17) + ((
      (m2_115 / ((d_114 * d_114) * 3.141593))
     * tmpvar_123) * SpecularMask2_16)))
   * 
    (1.0 - vertexColorW_15)
  ) + (
    (tmpvar_92 * BRDF1_113)
   * vertexColorW_15)));
  SpecRadiance_6 = (SpecRadiance_6 + ((
    (((tmpvar_124 * tmpvar_90) * (SpecularMask1_17 * EnvInfo.w)) * (5.0 * cEnvStrength))
   * 
    (1.0 - vertexColorW_15)
  ) + (
    (((sampleEnvSpecular_132 * tmpvar_124) * tmpvar_26.z) * ((SpecularMask2_16 * (1.0 - vertexColorW_15)) + vertexColorW_15))
   * 
    dot (tmpvar_90, float3(0.3, 0.59, 0.11))
  )));
   float tmpvar_137;
  tmpvar_137 = (((SpecularMask2_16 + SpecularMask1_17) * (1.0 - vertexColorW_15)) + vertexColorW_15).x;
  specularMask_5 = tmpvar_137;
   float tmpvar_138;
  tmpvar_138 = clamp (Roughness_18, 0.0, 1.0);
   float3 SpecularColor_139;
  SpecularColor_139 = (float3(0.04, 0.04, 0.04) * specularMask_5);
   float Roughness_140;
  Roughness_140 = tmpvar_138;
   float3 DiffLit_141;
  DiffLit_141 = DiffuseIrradiance_7;
   float3 lighting_142;
  lighting_142 = float3(0.0, 0.0, 0.0);
  if ((Lights0[3].w > 0.0)) {
     float D_143;
     float m2_144;
     float Atten_145;
     float3 L_146;
     float3 tmpvar_147;


    tmpvar_147 = (Lights0[0].xyz - xlv_TEXCOORD1.xyz);


     float tmpvar_148;
    tmpvar_148 = sqrt(dot (tmpvar_147, tmpvar_147));
    L_146 = (tmpvar_147 / tmpvar_148);
     float tmpvar_149;
    tmpvar_149 = clamp (dot (tmpvar_35, L_146), 0.0, 1.0);
     float tmpvar_150;
    tmpvar_150 = clamp (((tmpvar_148 * Lights0[1].w) + Lights0[0].w), 0.0, 1.0);
    Atten_145 = (tmpvar_150 * tmpvar_150);
    DiffLit_141 = (DiffLit_141 + (Lights0[1].xyz * (tmpvar_149 * Atten_145)));
     float tmpvar_151;
    tmpvar_151 = ((Roughness_140 * Roughness_140) + 0.0002);
    m2_144 = tmpvar_151;
    m2_144 = (m2_144 * m2_144);
     float tmpvar_152;
    tmpvar_152 = clamp (dot (tmpvar_35, normalize(
      (tmpvar_36 + L_146)
    )), 0.0, 1.0);
     float tmpvar_153;
    tmpvar_153 = (((
      (tmpvar_152 * m2_144)
     - tmpvar_152) * tmpvar_152) + 1.0);
    D_143 = ((tmpvar_153 * tmpvar_153) + 1e-06);
    D_143 = ((0.25 * m2_144) / D_143);
    lighting_142 = ((Lights0[1].xyz * SpecularColor_139) * ((Atten_145 * tmpvar_149) * D_143));
  };
  if (((Lights1[3].w > 0.0) && (Lights1[2].w <= 0.0))) {
     float D_154;
     float m2_155;
     float spot_156;
     float Atten_157;
     float DoL_158;
     float NoL_159;
     float3 L_160;
   
   float4 Light0 = Lights1[0];
     
   float4 Light1 = Lights1[1];
  
   float3 Light2 = Lights1[3].xyz;

   float3 tmpvar_164 = (Light0.xyz - xlv_TEXCOORD1.xyz);

    L_160 = tmpvar_164;

     float tmpvar_165;

    tmpvar_165 = sqrt(dot (L_160, L_160));
    L_160 = (L_160 / tmpvar_165);
     float tmpvar_166;
    tmpvar_166 = clamp (dot (tmpvar_35, L_160), 0.0, 1.0);
    NoL_159 = tmpvar_166;

     float tmpvar_167;
    
   float3 y_168 = -(L_160);

    tmpvar_167 = dot (Lights1[2].xyz, y_168);
    DoL_158 = tmpvar_167;
     float tmpvar_169;
    tmpvar_169 = clamp (((tmpvar_165 * Light1.w) + Light0.w), 0.0, 1.0);
    Atten_157 = tmpvar_169;
    Atten_157 = (Atten_157 * Atten_157);
     float tmpvar_170;
    tmpvar_170 = pow (clamp ((
      (DoL_158 * Light2.y)
     + Light2.z), 0.0, 1.0), Light2.x);
    spot_156 = tmpvar_170;
     float tmpvar_171;
    tmpvar_171 = ((Roughness_140 * Roughness_140) + 0.0002);
    m2_155 = tmpvar_171;
    m2_155 = (m2_155 * m2_155);
    
    float tmpvar_172 = clamp (dot (tmpvar_35, normalize((tmpvar_36 + L_160))), 0.0, 1.0);


    float tmpvar_173 = ((((tmpvar_172 * m2_155)- tmpvar_172) * tmpvar_172) + 1.0);

    D_154 = ((tmpvar_173 * tmpvar_173) + 1e-06);

    D_154 = ((0.25 * m2_155) / D_154);

    lighting_142 = (lighting_142 + (((Lights1[1].xyz * SpecularColor_139)* ((Atten_157 * NoL_159) * D_154)) * spot_156));

    DiffLit_141 = (DiffLit_141 + (Light1.xyz * ((NoL_159 * Atten_157)* spot_156)));
};




  DiffuseIrradiance_7 = DiffLit_141;
  SpecRadiance_6 = (SpecRadiance_6 + lighting_142);
   float4 tmpvar_174;
  tmpvar_174.w = 1.0;
  tmpvar_174.xyz = (SpecRadiance_6 + ((DiffuseIrradiance_7 * BaseColor.xyz) / 3.141593));


  OUT_4.w = tmpvar_174.w;


  float4 EmssionMap = tex2D (sEmissionSampler, uv0.xy);

  emission_3 = EmssionMap;
   float tmpvar_176;
   float tmpvar_177;
  tmpvar_177 = (CameraPosPS.w - cEmissionScale.w);
  tmpvar_176 = clamp ((sin(
    ((6.283185 * tmpvar_177) * cEmissionScale.z)
  ) - 0.8), 0.0, 1.0);
   float tmpvar_178;
  tmpvar_178 = clamp ((sin(
    ((6.283185 * tmpvar_177) * cEmissionScale.z)
  ) - 0.8), 0.0, 1.0);

  emission_3.xyz = (emission_3.xyz * (emission_3.w * ((cEmissionScale.x * (1.0 - tmpvar_176))+ (cEmissionScale.y * tmpvar_178))));




  OUT_4.xyz = (tmpvar_174.xyz + emission_3.xyz);
   float3 tmpvar_179;
  tmpvar_179 = ((FogColor2.xyz * clamp (
    ((tmpvar_36.y * 5.0) + 1.0)
  , 0.0, 1.0)) + FogColor.xyz);
  fogColor_2 = tmpvar_179;
   float tmpvar_180;
  tmpvar_180 = clamp (dot (-(tmpvar_36), SunDirection.xyz), 0.0, 1.0);
  VoL_1 = tmpvar_180;
  fogColor_2 = (fogColor_2 + (FogColor3 * (VoL_1 * VoL_1)).xyz);
   float tmpvar_181;
  tmpvar_181 = (1.0 - xlv_TEXCOORD3.w);
  OUT_4.xyz = ((OUT_4.xyz * tmpvar_181) + ((
    (OUT_4.xyz * tmpvar_181)
   + fogColor_2) * xlv_TEXCOORD3.w));
  OUT_4.xyz = (OUT_4.xyz * EnvInfo.z);
  OUT_4.xyz = clamp (OUT_4.xyz, float3(0.0, 0.0, 0.0), float3(4.0, 4.0, 4.0));
   float3 tmpvar_182;
  tmpvar_182.x = FogColor.w;
  tmpvar_182.y = FogColor2.w;
  tmpvar_182.z = FogColor3.w;
  OUT_4.xyz = (OUT_4.xyz * tmpvar_182);
  OUT_4.xyz = (OUT_4.xyz / ((OUT_4.xyz * 0.9661836) + 0.180676));
  OUT_4.w = 1.0;
 // SV_Target = OUT_4;
			
			
				
				return OUT_4;
			}
			ENDCG
		}
	}
	   // CustomEditor "CharShaderEditor"
    FallBack "Diffuse"
}
