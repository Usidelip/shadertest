Shader "Unlit/Reflection"
{
	Properties
	{
		_Color("Color",Color)= (1,1,1,1)
		_ReflectColor("ReflectColor",Color)=(1,1,1,1)
		_ReflectAmount("Reflection Amount",range(0,1)) = 1
		_Cubemap("Reflection CubMap",Cube) = "_Skybox" {}
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
			#include "Lighting.cginc"
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal :normal;

			};

			struct v2f
			{
				float2 uv : TEXCOORD0;				
				float4 vertex : SV_POSITION;
				float3 worldNormal:TEXCOORD1;	
				float3 worldPos:TEXCOORD2;
				float3 worldViewDir:TEXCOORD3;
				float3 worldRefl:TEXCOORD4;


			};

			fixed4 _Color;
			fixed4 _ReflectColor;
			float _ReflectAmount;
			samplerCUBE _Cubemap;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.worldPos = UnityObjectToWorldDir(v.vertex);
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.worldRefl = reflect(-o.worldViewDir,o.worldNormal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				fixed3 worldViewDir = normalize(i.worldViewDir);
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

				fixed3 diffuse = _LightColor0.rgb * _Color.rgb * max(0,dot(worldNormal,worldLightDir));

				fixed3 reflection = texCUBE(_Cubemap,i.worldRefl).rgb * _ReflectColor.rgb;

				UNITY_LIGHT_ATTENUATION(atten,i,i.worldPos);

				fixed3 color = ambient + lerp(diffuse,reflection,_ReflectAmount)*atten;
				return fixed4(color,1);
			}
			ENDCG
		}
	}
}
                                                                                                                                                              