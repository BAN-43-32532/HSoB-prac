//----------------------------------------------------------------
//----------------------------------------------------------------
//　サンプラ
sampler Tex0	: register( s0 );
texture g_Texture;
sampler Samp0 = sampler_state
{
	Texture		= <g_Texture>;
	MipFilter	= LINEAR;	//　縮小間フィルタ（？）
	MinFilter	= LINEAR;	//　縮小フィルタ
	MagFilter	= LINEAR;	//　拡大フィルタ
	AddressU	= 1;		//　地続きのマッピングU
	AddressV	= 1;		//　地続きのマッピングV
};
float m_frame;
float4 m_color;
float4 m_pos;

float2 m_rtSize;
float2 m_texSize;

//----------------------------------------------------------------
//----------------------------------------------------------------
//　入出力
struct PS_INPUT
{
	float4 pos		: POSITION0;
	float2 tec0		: TEXCOORD0;
};
struct PS_OUTPUT
{
	float4 col	: COLOR0;
};

//----------------------------------------------------------------
//----------------------------------------------------------------
//　ピクセルシェーダ
PS_OUTPUT PS( PS_INPUT In )
{
	PS_OUTPUT Out = ( PS_OUTPUT )0;
	
	//　元テクスチャ
	float4 tex = tex2D( Tex0, In.tec0 );
	
	float ang = radians( In.tec0.y*(360*4) + m_frame*8 );
	
	//　拡縮値
	float2 m_cvTex2Rt = m_rtSize / m_texSize;
	//　座標連携
	float2 rtp = m_pos * ( 1 / m_rtSize );
	//　中央補正
	float2 cen = m_texSize / 2 * ( 1 / m_rtSize );
	//　サンプリング
	float4 samp = tex2D( Samp0, In.tec0 / m_cvTex2Rt + rtp - cen + float2( 0.01*sin(ang), 0 ) );
	
	Out.col.rgb = samp.rgb * m_color.rgb;
	Out.col.a = tex.a * samp.rgb * m_color.a;
	
	return Out;
}

//----------------------------------------------------------------
//----------------------------------------------------------------
//　テクニック
technique tcHeatHaze
{
	pass P0
	{
		PixelShader		= compile ps_3_0 PS();
	}
}

