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
texture g_Mask;
sampler SampMask = sampler_state
{
	Texture		= <g_Mask>;
	MipFilter	= LINEAR;	//　縮小間フィルタ（？）
	MinFilter	= LINEAR;	//　縮小フィルタ
	MagFilter	= LINEAR;	//　拡大フィルタ
	AddressU	= 1;		//　地続きのマッピングU
	AddressV	= 1;		//　地続きのマッピングV
};

// 輝度計算基礎
static const float3 LMC_W = float3(0.298912, 0.586611, 0.114478);

float m_frame;
float m_threshold;
float4 m_color;
float4 m_pos;

float2 m_rtSize;
float2 m_texSize;
float2 m_rectSize;
float2 m_addRect;
float2 m_scale;

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
	float4 msk = tex2D( SampMask, In.tec0*8 + float2( 0, m_frame/512 ) );
	
	//　TEX->RT変換値
	float2 m_cvTex2Rt = m_rtSize / ( m_texSize * m_scale );
	
	//　矩形調整値
	float2 rectv = (m_addRect * m_scale) * m_cvTex2Rt * ( 1 / m_rtSize );
	//　座標連携
	float2 rtp = m_pos * ( 1 / m_rtSize );
	//　中央補正
	float2 cen = ( m_rectSize * m_scale ) / 2 * ( 1 / m_rtSize );
	//　最終座標
	float2 lpos = (In.tec0 - rectv) / m_cvTex2Rt + rtp - cen;
	//　サンプリング
	float4 samp = tex2D( Samp0, lpos );
	//　輝度算出
	float lmc = msk.rgb * LMC_W;
	//　淵
	float _width = 0.1;
	float abyss = smoothstep(m_threshold - _width, m_threshold, lmc) - smoothstep(m_threshold, m_threshold + _width, lmc);
	
	if( m_threshold > lmc ){ discard; }
	
	Out.col.rgb = samp.rgb + tex.rgb + abyss * m_color.rgb;
	Out.col.a = tex.a * m_color.a * (1-abyss);
	
	return Out;
}

//----------------------------------------------------------------
//----------------------------------------------------------------
//　テクニック
technique tcDissolveNotRT
{
	pass P0
	{
		PixelShader		= compile ps_3_0 PS();
	}
}

