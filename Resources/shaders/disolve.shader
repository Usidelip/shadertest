// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/disolve"
{
	Properties
	{
		_MainTex("MainTex",2D) = "white" {}
		_BurnMap("BurnMap",2D) = "white" {}
		_BumpMap("BumpMap",2D) = "bump" {}
		_BurnFirstColor("BurnFirstColor",Color) = (1,1,1,1)
		_BurnSecondColor("BurnSecondColor",Color) = (1,1,1,1)
		_BurnAmount("BurnAmount",Range(0.0,1.0)) = 0.0
		_LineWidth("LineWidth",Range(0.0,0.5)) = 0.1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags {"LightMode"="ForwardBase"}
			Cull Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityCG.cginc"
			#pragma multi_compile_fwdbase
		
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float2 uvMainTex : TEXCOORD0;
				float2 uvBumpMap:TEXCOORD1;
				float2 uvBurnMap:TEXCOORD2;
				float3 lightDir:TEXCOORD3;
				float3 worldPos:TEXCOORD4;
				SHADOW_COORDS(5)
				
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			sampler2D _BurnMap;
			float4 _BurnMap_ST;
			
			fixed3 _BurnFirstColor;
			fixed3 _BurnSecondColor;

			float _BurnAmount;
			float _LineWidth;
			
			v2f vert (a2v v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uvMainTex = TRANSFORM_TEX(v.texcoord,_MainTex);
				o.uvBumpMap = TRANSFORM_TEX(v.texcoord,_BumpMap);
				o.uvBurnMap = TRANSFORM_TEX(v.texcoord,_BurnMap);
				TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				o.worldPos = mul(unity_ObjectToWorld,v.vertex).xyz;
				TRANSFER_SHADOW(o);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed3 burn = tex2D(_BurnMap,i.uvBurnMap).rgb;
				clip(burn.r - _BurnAmount);
				float3 tangentLightDir = normalize(i.lightDir);
				float3 tangentNormal = UnpackNormal(tex2D(_BumpMap,i.uvBumpMap));
				fixed3 albedo = tex2D(_MainTex, i.uvMainTex).rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.rgb * albedo* max(0,dot(tangentNormal,tangentLightDir));
				fixed t= 1 - smoothstep(0.0,_LineWidth,burn.r - _BurnAmount);
				fixed addt = 1 - t;
				fixed3 burnColor = lerp(_BurnFirstColor,_BurnSecondColor,1);
				burnColor = pow(burnColor,5);
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);
				fixed3 finalColor = lerp(ambient+ diffuse * atten,burnColor,t*step(0.0001,_BurnAmount));
				//fixed3 finalColor = lerp(ambient + diffuse * atten,burnColor,t);
				return fixed4(finalColor,1.0);
			
			}
			ENDCG
		}
	}
}
