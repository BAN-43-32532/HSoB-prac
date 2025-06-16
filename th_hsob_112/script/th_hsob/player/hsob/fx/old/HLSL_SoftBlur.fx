
//　疑似乱数生成
float rand( float2 texCoord, int Seed )
{
	return frac(sin(dot(texCoord.xy, float2(12.9898, 78.233)) + Seed) * 43758.5453);
}

//　補完
float crnoise( float2 pos, int Seed )
{
	float2 ip = floor(pos);
	float2 fp = smoothstep( 0, 1, frac(pos) );
	float4 a = float4(
		rand( ip + float2(0, 0), Seed ),
		rand( ip + float2(1, 0), Seed ),
		rand( ip + float2(0, 1), Seed ),
		rand( ip + float2(1, 1), Seed )
	);
	
	a.xy = lerp( a.xy, a.zw, fp.y );
	return lerp( a.x, a.y, fp.x );
}

//　パーリンノイズ
float perlin( float2 pos, int Seed )
{
	return
		(
			crnoise( pos * 8, Seed ) * 32 +
			crnoise( pos * 16, Seed ) * 16 +
			crnoise( pos * 32, Seed ) * 8 +
			crnoise( pos * 64, Seed ) * 4 +
			crnoise( pos * 128, Seed ) * 2 +
			crnoise( pos * 256, Seed ) * 1
		) / 64;
}


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
float m_seed;
float m_frame;
float m_count;
float m_alpha;
float m_param;

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
	
	float4 tex = tex2D( Samp0, In.tec0 );
	float per1 = perlin( In.tec0, m_seed );
	float per2 = perlin( In.tec0, m_seed + 1 );
	float4 pix;
	
	float samp_lp	= 8;	//　サンプリング回数
	float samp_wy	= 8;	//　サンプリングway数
	float dist		= 1;	//　サンプリング間隔
	for( float i = 0; i < samp_lp; ++i ){
		for( float j = 0; j < samp_wy; ++j ){
			float angle = radians( 45 + ( 360 / samp_wy ) * j + m_frame );
			pix += tex2D( Samp0, In.tec0 + float2( 0 + (i/640*dist) * cos(angle), 0 + (i/480*dist) * sin(angle) ) );
		}
	}
	pix = lerp( 0, pix / (samp_lp*samp_wy) * 32, 0.5f );
	
	Out.col.rgb = pix.rgb;
	Out.col.a = pix.rgb * m_param;
	
	return Out;
}

//----------------------------------------------------------------
//----------------------------------------------------------------
//　テクニック
technique tcSoftBlur
{
	pass P0
	{
		PixelShader		= compile ps_3_0 PS();
	}
}

