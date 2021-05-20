// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/bloom"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_LuminanceThreshold("Lumin",Float) = 0.5
		_BlurSize("Blur",Float) = 1.0
		_Bloom("Bloom",2D)= "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		CGINCLUDE
#include "UnityCG.cginc"
			sampler2D _MainTex;
			sampler2D _Bloom;
			half4 _MainTex_TexelSize;
		float _LuminanceThreshold;
		float _BlurSize;
		struct v2f {
			float4 pos :SV_POSITION;
			half2 uv :TEXCOORD0;
		};

		struct v2fBloom{
				float4 pos:SV_POSITION;
				float4 uv:TEXCOORD0;
		};

		struct v2fGaussian{
			float4 pos:SV_POSITION;
			half2 uv[5]:TEXCOORD0;
		};
		v2f vert(appdata_img data){
			v2f o;
			o.pos = UnityObjectToClipPos(data.vertex);
			o.uv = data.texcoord;
		return o;
	}
		fixed4 frame(v2f i):SV_Target{
			fixed4 c = tex2D(_MainTex,i.uv);
return c;
}

		v2fBloom vertBloom(appdata_img v)
		{
		v2fBloom o;
		o.pos = UnityObjectToClipPos(v.vertex);
		o.uv.xy = v.texcoord;
		o.uv.zw = v.texcoord;
		#if UNITY_UV_STARTS_AT_TOP
			if(_MainTex_TexelSize.y <0.0)
			{
				o.uv.w = 1.0 - o.uv.w;
			}
		#endif
		return o ;
		}

		fixed4 fragBloom(v2fBloom i):SV_Target{
			return tex2D(_MainTex,i.uv.xy) + tex2D(_Bloom,i.uv.zw);
		}
		
		v2f vertExtractBright(appdata_img v)
		{	v2f o;
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord;
			return o;
		}

		fixed luminance(fixed4 color){
			return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
		}

		fixed4 frameExtractBright(v2f i)	:	SV_Target{
			fixed4 c = tex2D(_MainTex,i.uv);
			fixed midres = clamp(luminance(c)  - _LuminanceThreshold,0.0,1.0);
			return c  * midres ;
		}

		v2fGaussian vertGaussianV(appdata_img i){
			v2fGaussian o;
			o.pos =UnityObjectToClipPos(i.vertex);
			half2 uv = i.texcoord;
			o.uv[0] = uv;
 			o.uv[1] = uv + float2(0.0,_MainTex_TexelSize.y * 1.0)*_BlurSize;
			o.uv[2] = uv - float2(0.0,_MainTex_TexelSize.y *1.0) * _BlurSize;
			o.uv[3] = uv + float2(0.0,_MainTex_TexelSize.y * 2.0) * _BlurSize;
			o.uv[4] = uv - float2(0.0,_MainTex_TexelSize.y * 2.0) * _BlurSize;
			return o;
		}

		v2fGaussian vertGaussianH(appdata_img i){
			v2fGaussian o;
			o.pos = UnityObjectToClipPos(i.vertex);
			half2 uv = i.texcoord;
			o.uv[0] = uv;
			o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0,0.0) *_BlurSize;
			o.uv[2] = uv - float2(_MainTex_TexelSize.x * 1.0,0.0) *_BlurSize;
			o.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0,0.0) *_BlurSize;
			o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0,0.0) *_BlurSize;
			return o;


		}

		fixed4 fragGaussian(v2fGaussian o):SV_Target{
			float weight[3] = {0.4026,0.2442,0.0545};
			fixed3 sum = tex2D(_MainTex,o.uv[0]).rgb * weight[0];
			for(int it = 1;it <3;it++){
				sum+= tex2D(_MainTex,o.uv[it]).rgb *weight[1];
				sum+= tex2D(_MainTex,o.uv[2*it]).rgb * weight[2];
			}
			return fixed4(sum,1.0);
		}
		ENDCG

		Pass{
		CGPROGRAM


		#pragma vertex vertExtractBright
		#pragma fragment frameExtractBright



		ENDCG
		}

		
		Pass{
		CGPROGRAM		
			#pragma vertex vertGaussianH
			#pragma fragment fragGaussian
		

		ENDCG
		}



		Pass{
		CGPROGRAM
			#pragma vertex vertGaussianV
			#pragma fragment fragGaussian
		

		ENDCG
		}
		Pass{
		CGPROGRAM
		#pragma vertex vertBloom
		#pragma fragment fragBloom
		ENDCG
		}

	}
}
