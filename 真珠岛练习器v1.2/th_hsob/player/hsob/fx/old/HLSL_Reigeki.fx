
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

//　pos1 から見た pos2 への角度を取得
float GetGapAngle( float2 pos1, float2 pos2 ){
	return atan2( pos2.y-pos1.y, pos2.x-pos1.x );
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
float m_x;
float m_y;

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
	
	//　距離減衰
	float2 pos = float2( m_x/1024, m_y/512 );
	float range = 0.25;
	float distAtoB = sqrt( pow(In.tec0.x-pos.x,2) + pow(In.tec0.y-pos.y,2) );
	//　pos座標から見た各ピクセル座標への角度
	float AtoB = GetGapAngle( In.tec0, pos );
	
	//　ノイズ
	float per1 = perlin( In.tec0, m_seed );
	float per2 = perlin( In.tec0, m_seed + 1 );
	float pnoise = lerp( per1, per2, m_count );
	float angle = AtoB + pnoise;
	
	float4 tex = tex2D( Tex0, In.tec0 + float2( 0.05*cos(angle), 0.05*sin(angle) ) );
	
	Out.col.rgb = tex.rgb;
	Out.col.gb -= 0.5;
	Out.col.a = ( tex.a - distAtoB*4 ) * m_alpha;
	
	return Out;
}

//----------------------------------------------------------------
//----------------------------------------------------------------
//　テクニック
technique tcReigeki
{
	pass P0
	{
		PixelShader		= compile ps_3_0 PS();
	}
}

