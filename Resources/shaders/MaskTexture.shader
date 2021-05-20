Shader "Unlit/MaskTexture"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BumpScale("BumpScale",float)= 1.0
		_Bump("Texture",2D) = "bump" {}
		_Color("Color",Color) = (1,1,1,1)
		_SpecularMask("SpecularMask",2D) = "white" {}
		_SpecularScale("SpecularScale",float) = 1.0
		_Gloss("Gloss",Range(8.0,256)) = 20
		_Specular("Specular",Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags{"LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag


			
			#include "Lighting.cginc"
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal :NORMAL;
				float4 tangent :TANGENT;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
			
				float4 vertex : SV_POSITION;
				float3 lightDir :TEXCOORD1;
				float3 viewDir:TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _BumpScale;
			sampler2D _Bump;
			fixed4 _Color;
			float _SpecularScale;
			float _Gloss;
			fixed4 _Specular;
			sampler2D _SpecularMask;
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);			
				TANGENT_SPACE_ROTATION;
				o.lightDir = mul(rotation,ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir = mul(rotation,ObjSpaceViewDir(v.vertex)).xyz;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed3 tangentLightDir = normalize(i.lightDir);
				fixed3 tangentViewDir = normalize(i.viewDir);
				fixed3 tangentNormal = UnpackNormal(tex2D(_Bump,i.uv));
				tangentNormal.xy *= _BumpScale;
				tangentNormal.z = sqrt(1-saturate(dot(tangentNormal.xy,tangentNormal.xy)));
				fixed3 albedo = tex2D(_MainTex,i.uv).rgb * _Color.rgb;
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
				fixed3 diffuse = _LightColor0.xyz * albedo *max(0,dot(tangentNormal,tangentLightDir));
				fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
				fixed specularMask = tex2D(_SpecularMask,i.uv).r *_SpecularScale;
				fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0,dot(tangentNormal,halfDir)),_Gloss) * specularMask;

				return fixed4(ambient + diffuse + specular,1.0);
			}
			ENDCG
		}
	}
}
