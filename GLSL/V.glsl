#version 300 es
uniform highp mat4 ViewProjVS;
uniform highp vec4 CameraPosVS;
uniform highp mat4 LightViewProjTex;
uniform highp vec4 FogInfo;
uniform highp vec4 SkeletonData[192];
uniform highp mat4 World;

//struct vertexin
in highp vec4 POSITION;
in highp vec4 COLOR;
in highp vec4 NORMAL;
in highp vec2 TEXCOORD0;
in highp vec4 TANGENT;
in highp vec4 BINORMAL;
in highp vec4 BLENDWEIGHT;
in highp  vec4 BLENDINDICES;

//struct vertexout
out highp vec4 xlv_TEXCOORD0;
out highp vec4 xlv_TEXCOORD1;
out highp vec4 xlv_TEXCOORD2;
out highp vec4 xlv_TEXCOORD3;
out highp vec3 xlv_TEXCOORD4;
out highp vec3 xlv_TEXCOORD5;
out highp vec4 xlv_TEXCOORD6;
out highp vec4 xlv_TEXCOORD7;
out highp vec4 xlv_COLOR;
void main ()
{
  highp vec3 tmpvar_1;
  highp vec4 tmpvar_2;

  tmpvar_2.w = 1.0;
  tmpvar_2.xyz = POSITION.xyz;



  tmpvar_1 = ((NORMAL.xyz * 2.0) - 1.0);


  highp vec3 tmpvar_3;
  tmpvar_3 = normalize(TANGENT.xyz);
  highp vec3 tmpvar_4;
  tmpvar_4 = normalize(BINORMAL.xyz);
  highp vec4 tmpvar_5;
  highp vec3 tmpvar_6;
  tmpvar_5.w = tmpvar_2.w;
  highp vec4 tmpvar_7;
  tmpvar_7 = vec4(BLENDINDICES);
  highp int idx_8;
  idx_8 = int(tmpvar_7.x);
  highp int idx_9;
  idx_9 = int(tmpvar_7.y);
  highp int idx_10;
  idx_10 = int(tmpvar_7.z);
  highp int idx_11;
  idx_11 = int(tmpvar_7.w);
  highp vec4 tmpvar_12;
  tmpvar_12 = (((
    (BLENDWEIGHT.x * SkeletonData[(3 * idx_8)])
   + 
    (BLENDWEIGHT.y * SkeletonData[(3 * idx_9)])
  ) + (BLENDWEIGHT.z * SkeletonData[
    (3 * idx_10)
  ])) + (BLENDWEIGHT.w * SkeletonData[(3 * idx_11)]));
  highp vec4 tmpvar_13;
  tmpvar_13 = (((
    (BLENDWEIGHT.x * SkeletonData[((3 * idx_8) + 1)])
   + 
    (BLENDWEIGHT.y * SkeletonData[((3 * idx_9) + 1)])
  ) + (BLENDWEIGHT.z * SkeletonData[
    ((3 * idx_10) + 1)
  ])) + (BLENDWEIGHT.w * SkeletonData[(
    (3 * idx_11)
   + 1)]));
  highp vec4 tmpvar_14;
  tmpvar_14 = (((
    (BLENDWEIGHT.x * SkeletonData[((3 * idx_8) + 2)])
   + 
    (BLENDWEIGHT.y * SkeletonData[((3 * idx_9) + 2)])
  ) + (BLENDWEIGHT.z * SkeletonData[
    ((3 * idx_10) + 2)
  ])) + (BLENDWEIGHT.w * SkeletonData[(
    (3 * idx_11)
   + 2)]));
  highp vec3 tmpvar_15;
  tmpvar_15.x = dot (tmpvar_12.xyz, POSITION.xyz);
  tmpvar_15.y = dot (tmpvar_13.xyz, POSITION.xyz);
  tmpvar_15.z = dot (tmpvar_14.xyz, POSITION.xyz);
  highp vec3 tmpvar_16;
  tmpvar_16.x = tmpvar_12.w;
  tmpvar_16.y = tmpvar_13.w;
  tmpvar_16.z = tmpvar_14.w;
  tmpvar_5.xyz = (tmpvar_15 + tmpvar_16);
  highp vec3 tmpvar_17;
  tmpvar_17.x = dot (tmpvar_12.xyz, tmpvar_1);
  tmpvar_17.y = dot (tmpvar_13.xyz, tmpvar_1);
  tmpvar_17.z = dot (tmpvar_14.xyz, tmpvar_1);
  highp vec3 tmpvar_18;
  tmpvar_18.x = dot (tmpvar_12.xyz, tmpvar_3);
  tmpvar_18.y = dot (tmpvar_13.xyz, tmpvar_3);
  tmpvar_18.z = dot (tmpvar_14.xyz, tmpvar_3);
  highp vec3 tmpvar_19;
  tmpvar_19.x = dot (tmpvar_12.xyz, tmpvar_4);
  tmpvar_19.y = dot (tmpvar_13.xyz, tmpvar_4);
  tmpvar_19.z = dot (tmpvar_14.xyz, tmpvar_4);
  tmpvar_6 = ((COLOR.zyx * 2.0) - 1.0);
  highp vec3 tmpvar_20;
  tmpvar_20.x = -(tmpvar_6.x);
  tmpvar_20.y = tmpvar_6.z;
  tmpvar_20.z = tmpvar_6.y;
  highp vec3 tmpvar_21;
  tmpvar_21.x = dot (tmpvar_12.xyz, tmpvar_20);
  tmpvar_21.y = dot (tmpvar_13.xyz, tmpvar_20);
  tmpvar_21.z = dot (tmpvar_14.xyz, tmpvar_20);
  tmpvar_6 = tmpvar_21;
  highp vec4 tmpvar_22;
  highp vec4 tmpvar_23;
  highp vec4 tmpvar_24;
  highp vec4 tmpvar_25;
  highp vec4 tmpvar_26;
  tmpvar_26.w = 1.0;
  tmpvar_26.xyz = tmpvar_5.xyz;
  highp vec4 tmpvar_27;
  tmpvar_27.w = 1.0;
  tmpvar_27.xyz = (tmpvar_26 * World).xyz;
  highp mat3 tmpvar_28;
  tmpvar_28[uint(0)] = World[uint(0)].xyz;
  tmpvar_28[1u] = World[1u].xyz;
  tmpvar_28[2u] = World[2u].xyz;
  tmpvar_22.xyz = normalize((tmpvar_17 * tmpvar_28));



  highp mat3 tmpvar_29;
  tmpvar_29[uint(0)] = nnnnnnnnnnnnn[uint(0)].xyz;
  tmpvar_29[1u] = World[1u].xyz;
  tmpvar_29[2u] = World[2u].xyz;




  highp mat3 tmpvar_30;
  tmpvar_30[uint(0)] = World[uint(0)].xyz;
  tmpvar_30[1u] = World[1u].xyz;
  tmpvar_30[2u] = World[2u].xyz;
  highp mat3 tmpvar_31;
  tmpvar_31[uint(0)] = World[uint(0)].xyz;
  tmpvar_31[1u] = World[1u].xyz;
  tmpvar_31[2u] = World[2u].xyz;

  tmpvar_25.xyz = normalize((tmpvar_21 * tmpvar_31));


  tmpvar_23.xyz = (tmpvar_27.xyz - CameraPosVS.xyz);
  highp float fHeightCoef_32;
  highp float tmpvar_33;
  tmpvar_33 = clamp (((tmpvar_27.y * FogInfo.z) + FogInfo.w), 0.0, 1.0);
  fHeightCoef_32 = (tmpvar_33 * tmpvar_33);
  fHeightCoef_32 = (fHeightCoef_32 * fHeightCoef_32);
  highp float tmpvar_34;
  tmpvar_34 = (1.0 - exp((
    -(max (0.0, (sqrt(
      dot (tmpvar_23.xyz, tmpvar_23.xyz)
    ) - FogInfo.x)))
   * 
    max ((FogInfo.y * fHeightCoef_32), (0.1 * FogInfo.y))
  )));
  tmpvar_23.w = (tmpvar_34 * tmpvar_34);
  tmpvar_24.xyz = vec3(0.0, 0.0, 0.0);
  tmpvar_24.w = 0.0;
  highp vec4 tmpvar_35;
  highp vec4 tmpvar_36;
  tmpvar_36.xyz = tmpvar_22.xyz;
  tmpvar_36.w = 0.0;
  highp vec4 tmpvar_37;
  tmpvar_37.w = 1.0;
  tmpvar_37.xyz = tmpvar_27.xyz;
  tmpvar_35 = (tmpvar_37 * ViewProjVS);
  tmpvar_22 = tmpvar_36;
  gl_Position.xyw = tmpvar_35.xyw;
  xlv_TEXCOORD0 = TEXCOORD0.xyxy;
  xlv_TEXCOORD1 = tmpvar_27;
  xlv_TEXCOORD2 = tmpvar_36;
  xlv_TEXCOORD3 = tmpvar_23;
  xlv_TEXCOORD4 = normalize(clamp ((tmpvar_18 * tmpvar_29), -2.0, 2.0));
  xlv_TEXCOORD5 = normalize(clamp ((tmpvar_19 * tmpvar_30), -2.0, 2.0));
  xlv_TEXCOORD6 = tmpvar_24;
  xlv_TEXCOORD7 = (tmpvar_27 * LightViewProjTex);
  xlv_COLOR = tmpvar_25;
  gl_Position.z = ((tmpvar_35.z * 2.0) - tmpvar_35.w);
}

