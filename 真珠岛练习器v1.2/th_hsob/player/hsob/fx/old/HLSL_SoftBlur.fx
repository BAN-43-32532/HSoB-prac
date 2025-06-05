
//�@�^����������
float rand( float2 texCoord, int Seed )
{
	return frac(sin(dot(texCoord.xy, float2(12.9898, 78.233)) + Seed) * 43758.5453);
}

//�@�⊮
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

//�@�p�[�����m�C�Y
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
//�@�T���v��
sampler Tex0	: register( s0 );
texture g_Texture;
sampler Samp0 = sampler_state
{
	Texture		= <g_Texture>;
	MipFilter	= LINEAR;	//�@�k���ԃt�B���^�i�H�j
	MinFilter	= LINEAR;	//�@�k���t�B���^
	MagFilter	= LINEAR;	//�@�g��t�B���^
	AddressU	= 1;		//�@�n�����̃}�b�s���OU
	AddressV	= 1;		//�@�n�����̃}�b�s���OV
};
float m_seed;
float m_frame;
float m_count;
float m_alpha;
float m_param;

//----------------------------------------------------------------
//----------------------------------------------------------------
//�@���o��
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
//�@�s�N�Z���V�F�[�_
PS_OUTPUT PS( PS_INPUT In )
{
	PS_OUTPUT Out = ( PS_OUTPUT )0;
	
	float4 tex = tex2D( Samp0, In.tec0 );
	float per1 = perlin( In.tec0, m_seed );
	float per2 = perlin( In.tec0, m_seed + 1 );
	float4 pix;
	
	float samp_lp	= 8;	//�@�T���v�����O��
	float samp_wy	= 8;	//�@�T���v�����Oway��
	float dist		= 1;	//�@�T���v�����O�Ԋu
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
//�@�e�N�j�b�N
technique tcSoftBlur
{
	pass P0
	{
		PixelShader		= compile ps_3_0 PS();
	}
}

