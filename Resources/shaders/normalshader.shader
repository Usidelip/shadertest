Shader "Unlit/normalshader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
			sampler2D _CameraDepthTexture;
			float4x4 _CurrentViewProjectionInverseMatrix;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				half2 uv_depth : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				half2 uv_depth : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.uv_depth = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture,i.uv);
				float4 H = float4(i.uv.x *2 - 1,i.uv.y * 2 - 1, d* 2 - 1,1);
				float4 D = mul(_CurrentViewProjectionInverseMatrix,H);
				float4 worldPos = D / D.w;		
				float lineardepth = Linear01Depth(d);
				float linearP = H.z * 0.5 + 0.5;
				//return fixed4(linearP,linearP,linearP  ,1);
				//return fixed4(d,d,d,1);
				//return fixed4(D.z,D.z,D.z  ,1);
				//return fixed4(worldPos.x,worldPos.y,worldPos.z  ,1);
				return fixed4(lineardepth,lineardepth,lineardepth,1);
			}
			ENDCG
		}
	}
}
