//----------------------------------------------------------------
//----------------------------------------------------------------
//�@�T���v��
sampler Tex0	: register( s0 );
float m_frame;
float4 m_color;
float4 t_color;
float m_alpha;

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
	float4 pix;
	
	float samp_lp	= 16;	//�@�T���v�����O��
	float samp_wy	= 2;	//�@�T���v�����Oway��
	float dist		= 8;	//�@�T���v�����O�Ԋu
	for( float i = 0; i < samp_lp; ++i ){
		for( float j = 0; j < samp_wy; ++j ){
			float angle = radians( 45 + j * ( 360 / samp_wy ) + m_frame );
			pix += tex2D( Tex0, In.tec0 + float2( (i/512*dist) * cos(angle), (i/512*dist) * sin(angle) ) );
		}
	}
	pix = pix / ( samp_lp / 8 );
	
	Out.col.rgb = tex.rgb * t_color.rgb + pix.rgb * m_color.rgb;
	Out.col.a = min(tex.a * pix.a, 1.0) * m_alpha;
	
	return Out;
}

//----------------------------------------------------------------
//----------------------------------------------------------------
//�@�e�N�j�b�N
technique tcSoftBlur2
{
	pass P0
	{
		PixelShader		= compile ps_3_0 PS();
	}
}

