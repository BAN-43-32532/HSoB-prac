
//================================================================
//大域設定値
//Texture
sampler sampler0_ : register(s0);

//--------------------------------
float m_frame;
float m_alpha;

float rand(float2 co)
{
    return frac(sin(dot(co.xy ,float2(12.9898,78.233))) * 43758.5453);
}
//================================================================
//--------------------------------
//ピクセルシェーダ入力値
struct PS_INPUT
{
	float4 diffuse : COLOR0;  //ディフューズ色
	float2 texCoord : TEXCOORD0; //テクスチャ座標
	float2 vPos : VPOS; //描画先座標
};

//--------------------------------
//ピクセルシェーダ出力値
struct PS_OUTPUT
{
	float4 color : COLOR0; //出力色
};


//================================================================
// シェーダ
//--------------------------------
//ピクセルシェーダ
PS_OUTPUT PS( PS_INPUT In ) : COLOR0
{
	PS_OUTPUT Out;

	//--------------------------------
	//テクスチャの色
	float4 colorTexture = tex2D(sampler0_, In.texCoord);

	//頂点ディフーズ色
	float4 colorDiffuse = In.diffuse;

	//合成
	float4 color = colorTexture * colorDiffuse;
	
	float2 seedxy;
	seedxy.x = round(In.texCoord.x*64.0f);
	seedxy.y = round(In.texCoord.y*32.0f);
	float al = m_alpha*2.0f - (1.0f - seedxy.y/32.0f);
	float cl = clamp((1.0 - al*(1.0f+rand(seedxy)*7.0f)), 0.0f, 1.0f);
//	color.rgb *= cl;
	color.a = cl;

	Out.color = color;
	return Out;
}


//================================================================
//--------------------------------
//technique
technique tcTransEx
{
	pass P0
	{
		PixelShader = compile ps_3_0 PS();
	}
}

