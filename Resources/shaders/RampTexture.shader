// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/RampTexture"
{
	Properties
	{
		_RampTex("RampTex",2D) = "white" {}
		_Gloss("Gloss",range(8.0,256)) = 20
		_Color("Color Hint",Color) = (1,1,1,1)
		_Specular("Specular",Color) = (1,1,1,1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Tags {"LightMode"="ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				half3 normal:NORMAL;

			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 worldNormal:TEXCOORD1;
				float3 worldPos:TEXCOORD2;
				
			};


			
			sampler2D _RampTex;
			float4 _RampTex_ST;
			fixed4 _Specular;
			float _Gloss;
			fixed4 _Color;



			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _RampTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				// apply fog

				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
				fixed halfLambert = 0.5 * dot(worldNormal,worldLightDir) + 0.5;
				fixed2 res = fixed2(halfLambert,halfLambert);
				fixed3 diffuseColor = tex2D(_RampTex,res);
				diffuseColor = diffuseColor.rgb * _Color.rgb;
				fixed3 diffuse = _LightColor0.rgb * diffuseColor;

				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
				fixed3 halfDir = normalize(worldLightDir+viewDir);
				fixed3 specular = _Specular.rgb * _LightColor0.rgb * pow(max(0,dot(worldNormal,halfDir)),_Gloss);

				return fixed4(specular + diffuse ,1.0);
			}
			ENDCG
		}
	}
}
