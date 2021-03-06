#version 300 es
uniform highp vec4 CameraPosPS;
uniform highp vec4 EnvInfo;
uniform highp vec4 SunColor;
uniform highp vec4 SunDirection;
uniform highp vec4 FogColor;
uniform highp vec4 ShadowColor;
uniform highp vec4 FogColor2;
uniform highp vec4 FogColor3;
uniform highp vec4 Lights0[4];
uniform highp vec4 Lights1[4];
uniform highp vec4 cShadowBias;
uniform highp vec4 cPointCloud[6];
uniform highp vec4 cVirtualLitDir;
uniform highp vec4 cVirtualLitColor;
uniform highp float maokong_intensity;
uniform highp float cEnvStrength;
uniform highp float RoughnessOffset1;
uniform highp float RoughnessOffset2;
uniform highp float cDetailUVScale;
uniform highp float cSSSIntensity;
uniform highp float cBaseMapBias;
uniform highp float cNormalMapBias;
uniform highp vec4 cEmissionScale;
uniform highp vec4 _SkinSpec_color1;
uniform highp vec4 _SkinSpec_color2;
uniform highp vec4 cSSSColor;
uniform highp sampler2D sBaseSampler;
uniform highp sampler2D sMixSampler;
uniform highp sampler2D sNormalSampler;
uniform highp sampler2D sDetailNormalSampler;
uniform highp sampler2D sLutMapSampler;
uniform highp sampler2D sEnvSampler;
uniform highp sampler2D sShadowMapSampler;
uniform highp sampler2D sEmissionSampler;
in highp vec4 xlv_TEXCOORD0;
in highp vec4 xlv_TEXCOORD1;
in highp vec4 xlv_TEXCOORD2;
in highp vec4 xlv_TEXCOORD3;
in highp vec3 xlv_TEXCOORD4;
in highp vec3 xlv_TEXCOORD5;
in highp vec4 xlv_TEXCOORD6;
in highp vec4 xlv_TEXCOORD7;
in highp vec4 xlv_COLOR;
out highp vec4 SV_Target;
void main ()
{
  mediump float VoL_1;
  mediump vec3 fogColor_2;
  mediump vec4 emission_3;
  highp vec4 OUT_4;
  mediump float specularMask_5;
  highp vec3 SpecRadiance_6;
  highp vec3 DiffuseIrradiance_7;
  mediump vec2 inRange_8;
  highp float inShadow_9;
  mediump float shadow_10;
  highp float F1_11;
  mediump float NoL_12;
  mediump float NoV_13;
  mediump vec4 tangentNormal_14;
  mediump float vertexColorW_15;
  highp vec3 SpecularMask2_16;
  highp vec3 SpecularMask1_17;
  highp float Roughness_18;
  highp vec4 BaseColor_19;
  highp vec4 tmpvar_20;
  tmpvar_20 = texture (sBaseSampler, xlv_TEXCOORD0.xy, cBaseMapBias);
  BaseColor_19.w = tmpvar_20.w;
  BaseColor_19.xyz = (tmpvar_20.xyz * tmpvar_20.xyz);
  mediump float Roughness_21;
  Roughness_21 = max ((1.0 - tmpvar_20.w), 0.03);
  mediump float rain_22;
  highp float tmpvar_23;
  tmpvar_23 = (EnvInfo.x * 0.5);
  rain_22 = tmpvar_23;
  highp float tmpvar_24;
  tmpvar_24 = clamp (((
    (3.0 * xlv_TEXCOORD2.y)
   + 0.2) + (0.1 * rain_22)), 0.0, 1.0);
  rain_22 = (1.0 - (rain_22 * tmpvar_24));
  mediump float tmpvar_25;
  tmpvar_25 = clamp ((rain_22 * Roughness_21), 0.05, 1.0);
  Roughness_18 = tmpvar_25;
  highp vec4 tmpvar_26;
  tmpvar_26 = texture (sMixSampler, xlv_TEXCOORD0.xy);
  BaseColor_19.xyz = ((BaseColor_19.xyz * (1.0 - tmpvar_26.w)) + ((BaseColor_19.xyz * vec3(1.35, 1.2, 1.3)) * tmpvar_26.w));
  highp float tmpvar_27;
  tmpvar_27 = (1.0 - tmpvar_26.w);
  vertexColorW_15 = tmpvar_27;
  highp vec4 tmpvar_28;
  tmpvar_28 = texture (sNormalSampler, xlv_TEXCOORD0.xy, cNormalMapBias);
  tangentNormal_14 = tmpvar_28;
  tangentNormal_14.xyz = ((tangentNormal_14.xyz * 2.0) - 1.0);
  highp vec3 tmpvar_29;
  tmpvar_29 = normalize(((
    (normalize(xlv_TEXCOORD4) * tangentNormal_14.x)
   + 
    (normalize(xlv_TEXCOORD5) * tangentNormal_14.y)
  ) + (
    normalize(xlv_TEXCOORD2.xyz)
   * tangentNormal_14.z)));
  highp vec4 tmpvar_30;
  tmpvar_30 = texture (sDetailNormalSampler, (xlv_TEXCOORD0.xy * cDetailUVScale));
  highp vec3 tmpvar_31;
  tmpvar_31.z = 0.0;
  tmpvar_31.x = ((tmpvar_30.z * 2.0) - 1.0);
  tmpvar_31.y = ((tmpvar_30.w * 2.0) - 1.0);
  highp vec3 tmpvar_32;
  tmpvar_32 = normalize((tangentNormal_14.xyz + (
    (tmpvar_31 * 0.2)
   * 
    (maokong_intensity * tangentNormal_14.w)
  )));
  highp vec3 tmpvar_33;
  tmpvar_33 = normalize(((
    (xlv_TEXCOORD4 * tmpvar_32.x)
   + 
    (xlv_TEXCOORD5 * tmpvar_32.y)
  ) + (xlv_TEXCOORD2.xyz * tmpvar_32.z)));
  SpecularMask1_17 = (tmpvar_30.xxx * _SkinSpec_color1.xyz);
  SpecularMask2_16 = (tmpvar_30.yyy * _SkinSpec_color2.xyz);
  highp vec3 tmpvar_34;
  tmpvar_34 = normalize(xlv_COLOR.xyz);
  highp vec3 tmpvar_35;
  tmpvar_35 = normalize(((tmpvar_33 * 
    (1.0 - tmpvar_26.x)
  ) + (tmpvar_34 * tmpvar_26.x)));
  highp vec3 tmpvar_36;
  tmpvar_36 = normalize(-(xlv_TEXCOORD3.xyz));
  highp vec3 I_37;
  I_37 = -(tmpvar_36);
  highp float tmpvar_38;
  tmpvar_38 = clamp (dot (tmpvar_29, tmpvar_36), 0.0, 1.0);
  NoV_13 = tmpvar_38;
  highp float tmpvar_39;
  tmpvar_39 = clamp (dot (tmpvar_29, SunDirection.xyz), 0.0, 1.0);
  NoL_12 = tmpvar_39;
  mediump float tmpvar_40;
  tmpvar_40 = (1.0 - NoV_13);
  F1_11 = tmpvar_40;
  F1_11 = (F1_11 * F1_11);
  SpecularMask1_17 = ((SpecularMask1_17 * (1.0 - F1_11)) + (0.5 * F1_11));
  SpecularMask2_16 = ((SpecularMask2_16 * (1.0 - F1_11)) + (0.5 * F1_11));
  highp vec3 tmpvar_41;
  tmpvar_41 = (xlv_TEXCOORD7.xyz / xlv_TEXCOORD7.w);
  highp float tmpvar_42;
  tmpvar_42 = min (0.99999, tmpvar_41.z);
  highp vec2 tmpvar_43;
  tmpvar_43 = vec2(lessThan (abs(
    (tmpvar_41.xy - 0.5)
  ), vec2(0.5, 0.5)));
  inRange_8 = tmpvar_43;
  inRange_8.x = (inRange_8.x * inRange_8.y);
  highp float inShadow_44;
  highp vec4 Values3_45;
  highp vec4 Values2_46;
  highp vec4 Values1_47;
  highp vec4 Values0_48;
  highp vec2 tmpvar_49;
  tmpvar_49 = ((tmpvar_41.xy / cShadowBias.ww) - 0.5);
  highp vec2 tmpvar_50;
  tmpvar_50 = fract(tmpvar_49);
  highp vec2 tmpvar_51;
  tmpvar_51 = ((floor(tmpvar_49) + 0.5) - vec2(1.0, 1.0));
  Values0_48.x = dot (texture (sShadowMapSampler, (tmpvar_51 * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values0_48.y = dot (texture (sShadowMapSampler, ((tmpvar_51 + vec2(1.0, 0.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values0_48.z = dot (texture (sShadowMapSampler, ((tmpvar_51 + vec2(2.0, 0.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values0_48.w = dot (texture (sShadowMapSampler, ((tmpvar_51 + vec2(3.0, 0.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec4 tmpvar_52;
  tmpvar_52 = clamp (((
    (Values0_48 - vec4(tmpvar_42))
   * 8000.0) + 1.0), 0.0, 1.0);
  Values0_48 = tmpvar_52;
  Values1_47.x = dot (texture (sShadowMapSampler, ((tmpvar_51 + vec2(0.0, 1.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values1_47.y = dot (texture (sShadowMapSampler, ((tmpvar_51 + vec2(1.0, 1.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values1_47.z = dot (texture (sShadowMapSampler, ((tmpvar_51 + vec2(2.0, 1.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values1_47.w = dot (texture (sShadowMapSampler, ((tmpvar_51 + vec2(3.0, 1.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec4 tmpvar_53;
  tmpvar_53 = clamp (((
    (Values1_47 - vec4(tmpvar_42))
   * 8000.0) + 1.0), 0.0, 1.0);
  Values1_47 = tmpvar_53;
  Values2_46.x = dot (texture (sShadowMapSampler, ((tmpvar_51 + vec2(0.0, 2.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values2_46.y = dot (texture (sShadowMapSampler, ((tmpvar_51 + vec2(1.0, 2.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values2_46.z = dot (texture (sShadowMapSampler, ((tmpvar_51 + vec2(2.0, 2.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values2_46.w = dot (texture (sShadowMapSampler, ((tmpvar_51 + vec2(3.0, 2.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec4 tmpvar_54;
  tmpvar_54 = clamp (((
    (Values2_46 - vec4(tmpvar_42))
   * 8000.0) + 1.0), 0.0, 1.0);
  Values2_46 = tmpvar_54;
  Values3_45.x = dot (texture (sShadowMapSampler, ((tmpvar_51 + vec2(0.0, 3.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values3_45.y = dot (texture (sShadowMapSampler, ((tmpvar_51 + vec2(1.0, 3.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values3_45.z = dot (texture (sShadowMapSampler, ((tmpvar_51 + vec2(2.0, 3.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  Values3_45.w = dot (texture (sShadowMapSampler, ((tmpvar_51 + vec2(3.0, 3.0)) * cShadowBias.ww)), vec4(1.0, 0.003921569, 1.53787e-05, 6.030863e-08));
  highp vec4 tmpvar_55;
  tmpvar_55 = clamp (((
    (Values3_45 - vec4(tmpvar_42))
   * 8000.0) + 1.0), 0.0, 1.0);
  Values3_45 = tmpvar_55;
  highp vec2 tmpvar_56;
  tmpvar_56.x = tmpvar_52.x;
  tmpvar_56.y = tmpvar_53.x;
  highp vec2 tmpvar_57;
  tmpvar_57.x = tmpvar_52.y;
  tmpvar_57.y = tmpvar_53.y;
  highp vec2 tmpvar_58;
  tmpvar_58 = ((tmpvar_56 * (1.0 - tmpvar_50.xx)) + (tmpvar_57 * tmpvar_50.xx));
  highp vec2 tmpvar_59;
  tmpvar_59.x = tmpvar_52.y;
  tmpvar_59.y = tmpvar_53.y;
  highp vec2 tmpvar_60;
  tmpvar_60.x = tmpvar_52.z;
  tmpvar_60.y = tmpvar_53.z;
  highp vec2 tmpvar_61;
  tmpvar_61 = ((tmpvar_59 * (1.0 - tmpvar_50.xx)) + (tmpvar_60 * tmpvar_50.xx));
  highp vec2 tmpvar_62;
  tmpvar_62.x = tmpvar_52.z;
  tmpvar_62.y = tmpvar_53.z;
  highp vec2 tmpvar_63;
  tmpvar_63.x = tmpvar_52.w;
  tmpvar_63.y = tmpvar_53.w;
  highp vec2 tmpvar_64;
  tmpvar_64 = ((tmpvar_62 * (1.0 - tmpvar_50.xx)) + (tmpvar_63 * tmpvar_50.xx));
  highp vec2 tmpvar_65;
  tmpvar_65.x = tmpvar_53.x;
  tmpvar_65.y = tmpvar_54.x;
  highp vec2 tmpvar_66;
  tmpvar_66.x = tmpvar_53.y;
  tmpvar_66.y = tmpvar_54.y;
  highp vec2 tmpvar_67;
  tmpvar_67 = ((tmpvar_65 * (1.0 - tmpvar_50.xx)) + (tmpvar_66 * tmpvar_50.xx));
  highp vec2 tmpvar_68;
  tmpvar_68.x = tmpvar_53.y;
  tmpvar_68.y = tmpvar_54.y;
  highp vec2 tmpvar_69;
  tmpvar_69.x = tmpvar_53.z;
  tmpvar_69.y = tmpvar_54.z;
  highp vec2 tmpvar_70;
  tmpvar_70 = ((tmpvar_68 * (1.0 - tmpvar_50.xx)) + (tmpvar_69 * tmpvar_50.xx));
  highp vec2 tmpvar_71;
  tmpvar_71.x = tmpvar_53.z;
  tmpvar_71.y = tmpvar_54.z;
  highp vec2 tmpvar_72;
  tmpvar_72.x = tmpvar_53.w;
  tmpvar_72.y = tmpvar_54.w;
  highp vec2 tmpvar_73;
  tmpvar_73 = ((tmpvar_71 * (1.0 - tmpvar_50.xx)) + (tmpvar_72 * tmpvar_50.xx));
  highp vec2 tmpvar_74;
  tmpvar_74.x = tmpvar_54.x;
  tmpvar_74.y = tmpvar_55.x;
  highp vec2 tmpvar_75;
  tmpvar_75.x = tmpvar_54.y;
  tmpvar_75.y = tmpvar_55.y;
  highp vec2 tmpvar_76;
  tmpvar_76 = ((tmpvar_74 * (1.0 - tmpvar_50.xx)) + (tmpvar_75 * tmpvar_50.xx));
  highp vec2 tmpvar_77;
  tmpvar_77.x = tmpvar_54.y;
  tmpvar_77.y = tmpvar_55.y;
  highp vec2 tmpvar_78;
  tmpvar_78.x = tmpvar_54.z;
  tmpvar_78.y = tmpvar_55.z;
  highp vec2 tmpvar_79;
  tmpvar_79 = ((tmpvar_77 * (1.0 - tmpvar_50.xx)) + (tmpvar_78 * tmpvar_50.xx));
  highp vec2 tmpvar_80;
  tmpvar_80.x = tmpvar_54.z;
  tmpvar_80.y = tmpvar_55.z;
  highp vec2 tmpvar_81;
  tmpvar_81.x = tmpvar_54.w;
  tmpvar_81.y = tmpvar_55.w;
  highp vec2 tmpvar_82;
  tmpvar_82 = ((tmpvar_80 * (1.0 - tmpvar_50.xx)) + (tmpvar_81 * tmpvar_50.xx));
  inShadow_44 = (((
    ((((
      ((((tmpvar_58.x * 
        (1.0 - tmpvar_50.y)
      ) + (tmpvar_58.y * tmpvar_50.y)) + ((tmpvar_61.x * 
        (1.0 - tmpvar_50.y)
      ) + (tmpvar_61.y * tmpvar_50.y))) + ((tmpvar_64.x * (1.0 - tmpvar_50.y)) + (tmpvar_64.y * tmpvar_50.y)))
     + 
      ((tmpvar_67.x * (1.0 - tmpvar_50.y)) + (tmpvar_67.y * tmpvar_50.y))
    ) + (
      (tmpvar_70.x * (1.0 - tmpvar_50.y))
     + 
      (tmpvar_70.y * tmpvar_50.y)
    )) + ((tmpvar_73.x * 
      (1.0 - tmpvar_50.y)
    ) + (tmpvar_73.y * tmpvar_50.y))) + ((tmpvar_76.x * (1.0 - tmpvar_50.y)) + (tmpvar_76.y * tmpvar_50.y)))
   + 
    ((tmpvar_79.x * (1.0 - tmpvar_50.y)) + (tmpvar_79.y * tmpvar_50.y))
  ) + (
    (tmpvar_82.x * (1.0 - tmpvar_50.y))
   + 
    (tmpvar_82.y * tmpvar_50.y)
  )) * 0.11111);
  inShadow_44 = (1.0 - inShadow_44);
  inShadow_9 = (inShadow_44 * inRange_8.x);
  inShadow_9 = (1.0 - inShadow_9);
  shadow_10 = inShadow_9;
  highp vec3 tmpvar_83;
  tmpvar_83 = ((SunColor.xyz * cPointCloud[0].w) * ShadowColor.y);
  mediump vec3 tmpvar_84;
  mediump vec4 linearColor_85;
  mediump vec3 nSquared_86;
  highp vec3 tmpvar_87;
  tmpvar_87 = (tmpvar_29 * tmpvar_29);
  nSquared_86 = tmpvar_87;


  highp ivec3 tmpvar_88;
  tmpvar_88 = ivec3(lessThan (tmpvar_29, vec3(0.0, 0.0, 0.0)));
  highp vec4 tmpvar_89;

  
  tmpvar_89 = (((nSquared_86.x * cPointCloud[tmpvar_88.x]) + (nSquared_86.y * cPointCloud[
    (tmpvar_88.y + 2)
  ])) + (nSquared_86.z * cPointCloud[(tmpvar_88.z + 4)]));
  linearColor_85 = tmpvar_89;
  tmpvar_84 = (linearColor_85.xyz * (ShadowColor.x * (10.0 + 
    ((cPointCloud[3].w * ShadowColor.z) * 100.0)
  )));
  highp vec3 tmpvar_90;
  tmpvar_90 = (tmpvar_84 * tmpvar_26.z);
  highp vec3 tmpvar_91;
  tmpvar_91 = normalize(cVirtualLitDir.xyz);
  highp vec3 tmpvar_92;
  tmpvar_92 = ((cVirtualLitColor.xyz * tmpvar_26.z) * vec3((0.444 + (0.556 * 
    clamp (dot (tmpvar_35, tmpvar_91), 0.0, 1.0)
  ))));
  highp float tmpvar_93;
  tmpvar_93 = clamp ((0.6 + dot (tmpvar_34, SunDirection.xyz)), 0.0, 1.0);
  highp vec2 tmpvar_94;
  tmpvar_94.x = ((0.5 * dot (tmpvar_29, SunDirection.xyz)) + 0.5);
  tmpvar_94.y = (cSSSIntensity * tmpvar_26.y);
  highp vec4 tmpvar_95;
  tmpvar_95 = texture (sLutMapSampler, tmpvar_94);
  highp float tmpvar_96;
  tmpvar_96 = (shadow_10 + ((
    clamp (dot (tmpvar_33, SunDirection.xyz), 0.0, 1.0)
   - NoL_12) * shadow_10));
  highp vec3 tmpvar_97;
  highp float tmpvar_98;
  tmpvar_98 = (1.0 - cSSSIntensity);
  tmpvar_97.x = ((sqrt(
    (tmpvar_96 + 0.0001)
  ) * (1.0 - tmpvar_98)) + (tmpvar_96 * tmpvar_98));
  tmpvar_97.yz = vec2(tmpvar_96);
  DiffuseIrradiance_7 = (((tmpvar_90 + 
    ((((
      ((tmpvar_83 + tmpvar_90) * tmpvar_26.x)
     * cSSSColor.xyz) * vec3(tmpvar_93)) * vec3(tmpvar_93)) * shadow_10)
  ) + tmpvar_92) + ((
    (((tmpvar_97 * tmpvar_97) * (tmpvar_95.xyz * tmpvar_95.xyz)) * (1.0 - vertexColorW_15))
   + 
    ((NoL_12 * shadow_10) * vertexColorW_15)
  ) * tmpvar_83));
  highp float tmpvar_99;
  tmpvar_99 = (((1.0 - 
    ((1.0 - Roughness_18) * RoughnessOffset1)
  ) * (1.0 - vertexColorW_15)) + (Roughness_18 * vertexColorW_15));
  highp float tmpvar_100;
  tmpvar_100 = (((Roughness_18 * RoughnessOffset2) * (1.0 - vertexColorW_15)) + (Roughness_18 * vertexColorW_15));
  highp float d_101;
  highp float m2_102;
  highp float m_103;
  highp vec3 tmpvar_104;
  tmpvar_104 = normalize((SunDirection.xyz + tmpvar_36));
  highp float tmpvar_105;
  tmpvar_105 = clamp (dot (tmpvar_33, tmpvar_104), 0.0, 1.0);
  highp float tmpvar_106;
  tmpvar_106 = clamp (dot (tmpvar_36, tmpvar_104), 0.0, 1.0);
  highp float tmpvar_107;
  tmpvar_107 = (tmpvar_99 * tmpvar_99);
  highp float tmpvar_108;
  tmpvar_108 = (tmpvar_107 * tmpvar_107);
  highp float tmpvar_109;
  tmpvar_109 = (((
    (tmpvar_105 * tmpvar_108)
   - tmpvar_105) * tmpvar_105) + 1.0);
  m_103 = (tmpvar_100 * tmpvar_100);
  m2_102 = (m_103 * m_103);
  d_101 = (((
    (tmpvar_105 * m2_102)
   - tmpvar_105) * tmpvar_105) + 1.0);
  highp vec3 tmpvar_110;
  tmpvar_110 = ((vec3(0.04, 0.04, 0.04) + (vec3(0.96, 0.96, 0.96) * 
    exp2((((-5.55473 * tmpvar_106) - 6.98316) * tmpvar_106))
  )) * 0.25);
  highp float tmpvar_111;
  tmpvar_111 = ((tmpvar_83 * NoL_12) * (2.0 * shadow_10)).x;
  highp float tmpvar_112;
  tmpvar_112 = (((tmpvar_108 / 
    ((tmpvar_109 * tmpvar_109) * 3.141593)
  ) * tmpvar_110) * tmpvar_111).x;
  highp vec3 BRDF1_113;
  highp float d_114;
  highp float m2_115;
  highp float m_116;
  highp vec3 tmpvar_117;
  tmpvar_117 = normalize((tmpvar_91 + tmpvar_36));
  highp float tmpvar_118;
  tmpvar_118 = clamp (dot (tmpvar_33, tmpvar_117), 0.0, 1.0);
  highp float tmpvar_119;
  tmpvar_119 = clamp (dot (tmpvar_36, tmpvar_117), 0.0, 1.0);
  highp float tmpvar_120;
  tmpvar_120 = (tmpvar_99 * tmpvar_99);
  highp float tmpvar_121;
  tmpvar_121 = (tmpvar_120 * tmpvar_120);
  highp float tmpvar_122;
  tmpvar_122 = (((
    (tmpvar_118 * tmpvar_121)
   - tmpvar_118) * tmpvar_118) + 1.0);
  m_116 = (tmpvar_100 * tmpvar_100);
  m2_115 = (m_116 * m_116);
  d_114 = (((
    (tmpvar_118 * m2_115)
   - tmpvar_118) * tmpvar_118) + 1.0);
  highp vec3 tmpvar_123;
  tmpvar_123 = ((vec3(0.04, 0.04, 0.04) + (vec3(0.96, 0.96, 0.96) * 
    exp2((((-5.55473 * tmpvar_119) - 6.98316) * tmpvar_119))
  )) * 0.25);
  BRDF1_113 = ((tmpvar_121 / (
    (tmpvar_122 * tmpvar_122)
   * 3.141593)) * tmpvar_123);
  mediump vec3 tmpvar_124;
  mediump float Roughness_125;
  Roughness_125 = Roughness_18;
  mediump vec4 tmpvar_126;
  tmpvar_126 = ((Roughness_125 * vec4(-1.0, -0.0275, -0.572, 0.022)) + vec4(1.0, 0.0425, 1.04, -0.04));
  mediump vec2 tmpvar_127;
  tmpvar_127 = ((vec2(-1.04, 1.04) * (
    (min ((tmpvar_126.x * tmpvar_126.x), exp2((-9.28 * NoV_13))) * tmpvar_126.x)
   + tmpvar_126.y)) + tmpvar_126.zw);
  tmpvar_124 = ((vec3(0.04, 0.04, 0.04) * tmpvar_127.x) + tmpvar_127.y);
  mediump float Roughness_128;
  Roughness_128 = tmpvar_100;
  highp vec3 R_129;
  R_129 = (I_37 - (2.0 * (
    dot (tmpvar_29, I_37)
   * tmpvar_29)));
  mediump vec4 srcColor_130;
  mediump float fSign_131;
  mediump vec3 sampleEnvSpecular_132;
  mediump float tmpvar_133;
  tmpvar_133 = (Roughness_128 / 0.17);
  highp float tmpvar_134;
  tmpvar_134 = float((R_129.z > 0.0));
  fSign_131 = tmpvar_134;
  mediump float tmpvar_135;
  tmpvar_135 = ((fSign_131 * 2.0) - 1.0);
  R_129.xy = (R_129.xy / ((R_129.z * tmpvar_135) + 1.0));
  R_129.xy = ((R_129.xy * vec2(0.25, -0.25)) + (0.25 + (0.5 * fSign_131)));
  highp vec4 tmpvar_136;
  tmpvar_136 = textureLod (sEnvSampler, R_129.xy, tmpvar_133);
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
    dot (tmpvar_90, vec3(0.3, 0.59, 0.11))
  )));
  highp float tmpvar_137;
  tmpvar_137 = (((SpecularMask2_16 + SpecularMask1_17) * (1.0 - vertexColorW_15)) + vertexColorW_15).x;
  specularMask_5 = tmpvar_137;
  highp float tmpvar_138;
  tmpvar_138 = clamp (Roughness_18, 0.0, 1.0);
  mediump vec3 SpecularColor_139;
  SpecularColor_139 = (vec3(0.04, 0.04, 0.04) * specularMask_5);
  mediump float Roughness_140;
  Roughness_140 = tmpvar_138;
  mediump vec3 DiffLit_141;
  DiffLit_141 = DiffuseIrradiance_7;
  mediump vec3 lighting_142;
  lighting_142 = vec3(0.0, 0.0, 0.0);
  if ((Lights0[3].w > 0.0)) {
    highp float D_143;
    highp float m2_144;
    highp float Atten_145;
    highp vec3 L_146;
    highp vec3 tmpvar_147;
    tmpvar_147 = (Lights0[0].xyz - xlv_TEXCOORD1.xyz);
    highp float tmpvar_148;
    tmpvar_148 = sqrt(dot (tmpvar_147, tmpvar_147));
    L_146 = (tmpvar_147 / tmpvar_148);
    highp float tmpvar_149;
    tmpvar_149 = clamp (dot (tmpvar_35, L_146), 0.0, 1.0);
    highp float tmpvar_150;
    tmpvar_150 = clamp (((tmpvar_148 * Lights0[1].w) + Lights0[0].w), 0.0, 1.0);
    Atten_145 = (tmpvar_150 * tmpvar_150);
    DiffLit_141 = (DiffLit_141 + (Lights0[1].xyz * (tmpvar_149 * Atten_145)));
    mediump float tmpvar_151;
    tmpvar_151 = ((Roughness_140 * Roughness_140) + 0.0002);
    m2_144 = tmpvar_151;
    m2_144 = (m2_144 * m2_144);
    highp float tmpvar_152;
    tmpvar_152 = clamp (dot (tmpvar_35, normalize(
      (tmpvar_36 + L_146)
    )), 0.0, 1.0);
    highp float tmpvar_153;
    tmpvar_153 = (((
      (tmpvar_152 * m2_144)
     - tmpvar_152) * tmpvar_152) + 1.0);
    D_143 = ((tmpvar_153 * tmpvar_153) + 1e-06);
    D_143 = ((0.25 * m2_144) / D_143);
    lighting_142 = ((Lights0[1].xyz * SpecularColor_139) * ((Atten_145 * tmpvar_149) * D_143));
  };
  if (((Lights1[3].w > 0.0) && (Lights1[2].w <= 0.0))) {
    highp float D_154;
    highp float m2_155;
    mediump float spot_156;
    mediump float Atten_157;
    mediump float DoL_158;
    mediump float NoL_159;
    mediump vec3 L_160;
    highp vec4 tmpvar_161;
    tmpvar_161 = Lights1[0];
    highp vec4 tmpvar_162;
    tmpvar_162 = Lights1[1];
    highp vec3 tmpvar_163;
    tmpvar_163 = Lights1[3].xyz;
    highp vec3 tmpvar_164;
    tmpvar_164 = (tmpvar_161.xyz - xlv_TEXCOORD1.xyz);
    L_160 = tmpvar_164;
    mediump float tmpvar_165;
    tmpvar_165 = sqrt(dot (L_160, L_160));
    L_160 = (L_160 / tmpvar_165);
    highp float tmpvar_166;
    tmpvar_166 = clamp (dot (tmpvar_35, L_160), 0.0, 1.0);
    NoL_159 = tmpvar_166;
    highp float tmpvar_167;
    mediump vec3 y_168;
    y_168 = -(L_160);
    tmpvar_167 = dot (Lights1[2].xyz, y_168);
    DoL_158 = tmpvar_167;
    highp float tmpvar_169;
    tmpvar_169 = clamp (((tmpvar_165 * tmpvar_162.w) + tmpvar_161.w), 0.0, 1.0);
    Atten_157 = tmpvar_169;
    Atten_157 = (Atten_157 * Atten_157);
    highp float tmpvar_170;
    tmpvar_170 = pow (clamp ((
      (DoL_158 * tmpvar_163.y)
     + tmpvar_163.z), 0.0, 1.0), tmpvar_163.x);
    spot_156 = tmpvar_170;
    mediump float tmpvar_171;
    tmpvar_171 = ((Roughness_140 * Roughness_140) + 0.0002);
    m2_155 = tmpvar_171;
    m2_155 = (m2_155 * m2_155);
    highp float tmpvar_172;
    tmpvar_172 = clamp (dot (tmpvar_35, normalize(
      (tmpvar_36 + L_160)
    )), 0.0, 1.0);
    highp float tmpvar_173;
    tmpvar_173 = (((
      (tmpvar_172 * m2_155)
     - tmpvar_172) * tmpvar_172) + 1.0);
    D_154 = ((tmpvar_173 * tmpvar_173) + 1e-06);
    D_154 = ((0.25 * m2_155) / D_154);
    lighting_142 = (lighting_142 + ((
      (Lights1[1].xyz * SpecularColor_139)
     * 
      ((Atten_157 * NoL_159) * D_154)
    ) * spot_156));
    DiffLit_141 = (DiffLit_141 + (tmpvar_162.xyz * (
      (NoL_159 * Atten_157)
     * spot_156)));
  };
  DiffuseIrradiance_7 = DiffLit_141;
  SpecRadiance_6 = (SpecRadiance_6 + lighting_142);
  highp vec4 tmpvar_174;
  tmpvar_174.w = 1.0;
  tmpvar_174.xyz = (SpecRadiance_6 + ((DiffuseIrradiance_7 * BaseColor_19.xyz) / 3.141593));
  OUT_4.w = tmpvar_174.w;
  highp vec4 tmpvar_175;
  tmpvar_175 = texture (sEmissionSampler, xlv_TEXCOORD0.xy);
  emission_3 = tmpvar_175;
  highp float tmpvar_176;
  highp float tmpvar_177;
  tmpvar_177 = (CameraPosPS.w - cEmissionScale.w);
  tmpvar_176 = clamp ((sin(
    ((6.283185 * tmpvar_177) * cEmissionScale.z)
  ) - 0.8), 0.0, 1.0);
  highp float tmpvar_178;
  tmpvar_178 = clamp ((sin(
    ((6.283185 * tmpvar_177) * cEmissionScale.z)
  ) - 0.8), 0.0, 1.0);
  emission_3.xyz = (emission_3.xyz * (emission_3.w * (
    (cEmissionScale.x * (1.0 - tmpvar_176))
   + 
    (cEmissionScale.y * tmpvar_178)
  )));
  OUT_4.xyz = (tmpvar_174.xyz + emission_3.xyz);
  highp vec3 tmpvar_179;
  tmpvar_179 = ((FogColor2.xyz * clamp (
    ((tmpvar_36.y * 5.0) + 1.0)
  , 0.0, 1.0)) + FogColor.xyz);
  fogColor_2 = tmpvar_179;
  highp float tmpvar_180;
  tmpvar_180 = clamp (dot (-(tmpvar_36), SunDirection.xyz), 0.0, 1.0);
  VoL_1 = tmpvar_180;
  fogColor_2 = (fogColor_2 + (FogColor3 * (VoL_1 * VoL_1)).xyz);
  highp float tmpvar_181;
  tmpvar_181 = (1.0 - xlv_TEXCOORD3.w);
  OUT_4.xyz = ((OUT_4.xyz * tmpvar_181) + ((
    (OUT_4.xyz * tmpvar_181)
   + fogColor_2) * xlv_TEXCOORD3.w));
  OUT_4.xyz = (OUT_4.xyz * EnvInfo.z);
  OUT_4.xyz = clamp (OUT_4.xyz, vec3(0.0, 0.0, 0.0), vec3(4.0, 4.0, 4.0));
  highp vec3 tmpvar_182;
  tmpvar_182.x = FogColor.w;
  tmpvar_182.y = FogColor2.w;
  tmpvar_182.z = FogColor3.w;
  OUT_4.xyz = (OUT_4.xyz * tmpvar_182);
  OUT_4.xyz = (OUT_4.xyz / ((OUT_4.xyz * 0.9661836) + 0.180676));
  OUT_4.w = 1.0;
  SV_Target = OUT_4;
}

