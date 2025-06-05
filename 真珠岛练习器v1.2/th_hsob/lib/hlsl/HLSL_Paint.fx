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
float4 m_playerPos;

float2 m_rtSize;
float2 m_texSize;
float2 m_rectSize;
float2 m_addRect;
float2 m_scale;

float box( float2 st, float size )
{
	size = 0.5 + size * 0.5;
	st = step(st, size) * step(1.0 - st, size);
	return st.x * st.y;
}

float rand( float2 st )
{
	return frac(sin(dot(st, float2(12.9898, 78.233))) * 43758.5453);
}

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
	
	//　TEX->RT変換値
	float2 m_cvTex2Rt = m_rtSize / ( m_texSize * m_scale );
	
	//　矩形調整値
	float2 rectv = (m_addRect * m_scale) * m_cvTex2Rt * ( 1 / m_rtSize );
	//　座標連携
	float2 rtp = m_pos * ( 1 / m_rtSize );
	float2 rtpPL = m_playerPos * ( 1 / m_rtSize );
	//　中央補正
	float2 cen = ( m_rectSize * m_scale ) / 2 * ( 1 / m_rtSize );
	//　最終座標
	float2 lpos = (In.tec0 - rectv) / m_cvTex2Rt + rtp - cen;
	//　サンプリング
	float4 samp = tex2D( Samp0, lpos );
	
	float ct = abs(m_frame / 16);
	
	float2 st = 0.5 - In.tec0;
	//float at = atan2( st.y, st.x );
	
	float n = 64;
	float2 sector = floor(In.tec0*n);
	float2 loops = frac(In.tec0*n);
	float d = distance( float2(0.5,0.5), sector / n );
	float offs = rand( sector ) * 8;
	
	float bx1 = box( loops, sin(offs+ct) + sin(d*32-ct) ) / 2;
	float bx2 = box( loops, (sin(offs+ct) + sin(d*32-ct)) / 2 ) / 2;
	
	Out.col.rgb = (bx1+bx2) * ( samp.rgb * m_color.rgb ) - smoothstep(0, distance(rtpPL,lpos), 0.05);
	Out.col.a = tex.a * m_color.a;
	
	return Out;
}

//----------------------------------------------------------------
//----------------------------------------------------------------
//　テクニック
technique tcPaint
{
	pass P0
	{
		PixelShader		= compile ps_3_0 PS();
	}
}

