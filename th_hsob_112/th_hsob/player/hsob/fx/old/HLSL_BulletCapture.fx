

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
float m_alpha;
float m_x;
float m_y;

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
	
	float4 tex = tex2D( Tex0, In.tec0 );
	
	float2 pos = float2( m_x/1024, m_y/512 );
	float range = 0.05;
	float distAtoB = sqrt( pow(In.tec0.x-pos.x,2) + pow(In.tec0.y-pos.y,2) );
	
	Out.col.rgb = tex.rgb;
	Out.col.gb += 0.75;
	Out.col.a = max( (range-distAtoB)/range, 0) * m_alpha;
	
	return Out;
}

//----------------------------------------------------------------
//----------------------------------------------------------------
//�@�e�N�j�b�N
technique tcBulletCapture
{
	pass P0
	{
		PixelShader		= compile ps_3_0 PS();
	}
}


//function AttenuationOfDistance( float v_param, float v_distance, float v_max ){
//	return max( v_max - v_distance * (v_param/v_max), v_param );
//}