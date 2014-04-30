Shader "Custom/Ripple Effects"
{
    Properties
    {
        _MainTex("Base (RGB)", 2D) = "white" {}
        _Params("Parameters", Vector) = (1, 1, 1, 1)
        _Drop1("Drop 1", Vector) = (0.333, 0.333, 0, 0)
        _Drop2("Drop 2", Vector) = (0.666, 0.666, 0, 0)
    }

    CGINCLUDE

    #include "UnityCG.cginc"

    struct v2f
    {
        float4 position : SV_POSITION;
        float2 uv : TEXCOORD0;
    };

    sampler2D _MainTex;
    float4 _Params;
    float3 _Drop1;
    float3 _Drop2;

    v2f vert(appdata_img v)
    {
        v2f o;
        o.position = mul(UNITY_MATRIX_MVP, v.vertex);
        o.uv = v.texcoord.xy;
        return o;
    }

    float wave(float2 position, float2 origin, float time)
    {
        float d = length(position - origin);
        float t = max(time * _Params.x - d, 0);
        return sin(t * _Params.z * 2 * 3.14159265f) * exp(-_Params.y * t);
    }

    half4 frag(v2f i) : SV_Target
    {
        float2 dx = float2(0.001f, 0);
        float2 dy = float2(0, 0.001f);

        float w = wave(i.uv, _Drop1.xy, _Drop1.z) + wave(i.uv, _Drop2.xy, _Drop2.z);
        float wdx = wave(i.uv + dx, _Drop1.xy, _Drop1.z) + wave(i.uv + dx, _Drop2.xy, _Drop2.z);
        float wdy = wave(i.uv + dy, _Drop1.xy, _Drop1.z) + wave(i.uv + dy, _Drop2.xy, _Drop2.z);

        float2 dd = float2(wdx - w, wdy - w);

        return tex2D(_MainTex, i.uv + dd) * (1.0f - length(dd) * 4);
    }

    ENDCG

    SubShader
    {
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            Fog { Mode off }
            CGPROGRAM
            #pragma fragmentoption ARB_precision_hint_fastest 
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    } 
}
