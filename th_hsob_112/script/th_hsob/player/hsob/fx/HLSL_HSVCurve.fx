//----------------------------------------------------------------
//----------------------------------------------------------------
//�@HSV�ϊ�
float4 RGB2HSV( float4 v_rgb )
{
	float4 ahsv;
	
	float RGBmax = max( v_rgb.r, max( v_rgb.g, v_rgb.b ) );
	float RGBmin = min( v_rgb.r, min( v_rgb.g, v_rgb.b ) );
	float delta = RGBmax - RGBmin;
	
	//�@A:���l
	ahsv.a = v_rgb.a;
	//�@V:���x
	ahsv.b = RGBmax;
	//�@S:�ʓx
	ahsv.g = ( RGBmax != 0.0 ) ? delta / RGBmax : 0.0;
	//�@H:�F��
	ahsv.r = ( v_rgb.r == RGBmax ) ? (v_rgb.g-v_rgb.b)/delta :
		( v_rgb.g == RGBmax ) ? 2+(v_rgb.b-v_rgb.r)/delta : 4+(v_rgb.r-v_rgb.g)/delta ;
	ahsv.r /= 6.0;
	ahsv.r += ( ahsv.r < 0 ) ? 1.0 : 0 ;
	
	return ahsv;
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
float m_frame;
float m_alpha;
float3 m_xyzw;


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
	float4 hsv = RGB2HSV( tex );
	float dPow = ( hsv.g + hsv.b ) / 200;
	float dAng = radians( hsv.r*360 );
	//�@�F���p��
	tex = tex2D( Tex0, In.tec0 + float2( dPow*cos( dAng ), dPow*sin( dAng ) ) + float2( (hsv.b/40)*sin(hsv.b*10+m_frame/20), 0 ) );
	//tex = tex2D( Tex0, In.tec0 + float2( (hsv.g/60)*sin(hsv.b*40+m_frame/10), 0 ) );
	
	tex.r = tex.r * m_xyzw.x;
	tex.g = tex.g * m_xyzw.y;
	tex.b = tex.b * m_xyzw.z;
	
	Out.col.rgb = tex.rgb;
	Out.col.a = tex.a * m_alpha;
	
	return Out;
}


//----------------------------------------------------------------
//----------------------------------------------------------------
//�@�e�N�j�b�N
technique tcHSVCurve
{
	pass P0
	{
		PixelShader		= compile ps_3_0 PS();
	}
}

