// Made with Amplify Shader Editor v1.9.2
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Foliage"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_FluffyScale("FluffyScale", Float) = 0
		_LightTransiSmoother("LightTransiSmoother", Float) = 1
		_BaseColor("BaseColor", Color) = (0.2357869,0.5188679,0.1501127,0)
		_Foliage("Foliage", 2D) = "white" {}
		_LeafColor("LeafColor", Color) = (0.1858186,0.754717,0.1756259,1)
		_smoothness("smoothness", Range( 0 , 1)) = 0
		_noiseSize("noiseSize", Float) = 0
		_windSpeed("windSpeed", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float _FluffyScale;
		uniform float _windSpeed;
		uniform float _noiseSize;
		uniform float4 _LeafColor;
		uniform sampler2D _Foliage;
		uniform float4 _Foliage_ST;
		uniform float _LightTransiSmoother;
		uniform float4 _BaseColor;
		uniform float _smoothness;
		uniform float _Cutoff = 0.5;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float2 temp_cast_0 = (-1.0).xx;
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float3 ase_worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
			half tangentSign = v.tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
			float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * tangentSign;
			float3x3 ase_tangentToWorldFast = float3x3(ase_worldTangent.x,ase_worldBitangent.x,ase_worldNormal.x,ase_worldTangent.y,ase_worldBitangent.y,ase_worldNormal.y,ase_worldTangent.z,ase_worldBitangent.z,ase_worldNormal.z);
			float3 tangentTobjectDir7 = normalize( mul( unity_WorldToObject, float4( mul( ase_tangentToWorldFast, float3( (temp_cast_0 + (v.texcoord.xy - float2( 0,0 )) * (float2( 1,1 ) - temp_cast_0) / (float2( 1,1 ) - float2( 0,0 ))) ,  0.0 ) ), 0 ) ).xyz );
			float4 transform6 = mul(unity_WorldToObject,float4( ( tangentTobjectDir7 * _FluffyScale ) , 0.0 ));
			float4 FaceOrientation8 = transform6;
			float3 ase_vertexNormal = v.normal.xyz;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult40 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 panner44 = ( ( _windSpeed * _Time.y ) * float2( 1,1 ) + ( appendResult40 * _noiseSize ));
			float simplePerlin2D43 = snoise( panner44 );
			simplePerlin2D43 = simplePerlin2D43*0.5 + 0.5;
			float Wind48 = simplePerlin2D43;
			float4 transform53 = mul(unity_WorldToObject,float4( ( ase_vertexNormal * Wind48 ) , 0.0 ));
			v.vertex.xyz += ( FaceOrientation8 + transform53 ).xyz;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Foliage = i.uv_texcoord * _Foliage_ST.xy + _Foliage_ST.zw;
			float4 tex2DNode27 = tex2D( _Foliage, uv_Foliage );
			float4 Leaf30 = ( _LeafColor * tex2DNode27 );
			o.Albedo = Leaf30.rgb;
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToWorldDir21 = mul( unity_ObjectToWorld, float4( ase_vertex3Pos, 0 ) ).xyz;
			float dotResult14 = dot( ase_worldViewDir , -( _WorldSpaceLightPos0.xyz + ( objToWorldDir21 * _LightTransiSmoother ) ) );
			float4 blendOpSrc35 = _BaseColor;
			float4 blendOpDest35 = Leaf30;
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 BackColor16 = ( saturate( dotResult14 ) * ( saturate( ( 1.0 - ( ( 1.0 - blendOpDest35) / max( blendOpSrc35, 0.00001) ) ) )) * ase_lightColor );
			o.Emission = BackColor16.rgb;
			o.Smoothness = _smoothness;
			o.Alpha = 1;
			float LeafAlpha31 = tex2DNode27.a;
			clip( LeafAlpha31 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19200
Node;AmplifyShaderEditor.CommentaryNode;54;-683.0266,469.8029;Inherit;False;704.4592;329.8941;;4;50;53;49;51;Add wind motion;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;38;-2433.488,-1425.573;Inherit;False;980.0862;516.6671;;5;27;29;28;30;31;Texture Stuff;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;26;-2970.291,214.1799;Inherit;False;2127.401;549.9434;;16;12;14;15;18;13;21;19;20;22;23;24;25;16;35;36;37;BackColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;10;-2099.336,-548.828;Inherit;False;1602.814;378.063;;8;1;2;3;7;4;5;6;8;Face Orientation;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-2049.336,-498.828;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TFHCRemapNode;2;-1768.336,-498.828;Inherit;True;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,1;False;3;FLOAT2;0,0;False;4;FLOAT2;1,1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-2025.336,-339.8282;Inherit;False;Constant;_Float0;Float 0;0;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-1213.05,-450.4315;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;6;-1036.257,-451.4424;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-738.5221,-412.3996;Inherit;False;FaceOrientation;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;15;-1565.89,370.6027;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-1084.89,375.6027;Inherit;False;BackColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;49.0387,-34.17139;Inherit;False;16;BackColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-4.236511,-138.6938;Inherit;False;30;Leaf;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;345,-109;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;Foliage;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;TransparentCutout;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;14.76349,148.3062;Inherit;False;31;LeafAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-3.236511,52.30618;Inherit;False;Property;_smoothness;smoothness;6;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;25;-1765.291,480.4565;Inherit;False;Property;_BaseColor;BaseColor;3;0;Create;True;0;0;0;False;0;False;0.2357869,0.5188679,0.1501127,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;36;-1752.947,666.7246;Inherit;False;30;Leaf;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;-1242.291,389.4565;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;35;-1496.237,505.3062;Inherit;False;ColorBurn;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;37;-1470.947,633.7246;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;27;-2383.488,-1181.439;Inherit;True;Property;_Foliage;Foliage;4;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;-1969.401,-1239.573;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;28;-2344.401,-1375.573;Inherit;False;Property;_LeafColor;LeafColor;5;0;Create;True;0;0;0;False;0;False;0.1858186,0.754717,0.1756259,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;-1695.402,-1198.573;Inherit;False;Leaf;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-1984.401,-1021.572;Inherit;False;LeafAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;39;-2819.028,1275.925;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;40;-2566.047,1268.749;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-2295.047,1322.749;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-2566.047,1448.749;Inherit;False;Property;_noiseSize;noiseSize;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;43;-1815.047,1345.749;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;45;-2536.047,1667.749;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-2489.047,1574.749;Inherit;False;Property;_windSpeed;windSpeed;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-2256.047,1596.749;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-1527.047,1359.749;Inherit;False;Wind;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;52;68.38086,390.4639;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PannerNode;44;-2051.047,1351.749;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;9;-198.4886,359.9561;Inherit;False;8;FaceOrientation;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-406.0273,614.8026;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldToObjectTransfNode;53;-220.5678,590.9811;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;49;-629.0266,677.8026;Inherit;False;48;Wind;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;51;-633.0266,519.8029;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NegateNode;18;-1982.291,480.4565;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightPos;13;-2509.89,323.6027;Inherit;False;0;3;FLOAT4;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.TransformDirectionNode;21;-2634.291,485.4565;Inherit;False;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;19;-2362.291,534.4565;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-2661.291,651.4565;Inherit;False;Property;_LightTransiSmoother;LightTransiSmoother;2;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;22;-2147.291,484.4565;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PosVertexDataNode;23;-2920.291,461.4565;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;14;-1772.89,353.6027;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;12;-2126.64,264.1799;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;5;-1459.05,-283.4316;Inherit;False;Property;_FluffyScale;FluffyScale;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TransformDirectionNode;7;-1469.721,-486.5161;Inherit;False;Tangent;Object;True;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
WireConnection;2;0;1;0
WireConnection;2;3;3;0
WireConnection;4;0;7;0
WireConnection;4;1;5;0
WireConnection;6;0;4;0
WireConnection;8;0;6;0
WireConnection;15;0;14;0
WireConnection;16;0;24;0
WireConnection;0;0;32;0
WireConnection;0;2;17;0
WireConnection;0;4;34;0
WireConnection;0;10;33;0
WireConnection;0;11;52;0
WireConnection;24;0;15;0
WireConnection;24;1;35;0
WireConnection;24;2;37;0
WireConnection;35;0;25;0
WireConnection;35;1;36;0
WireConnection;29;0;28;0
WireConnection;29;1;27;0
WireConnection;30;0;29;0
WireConnection;31;0;27;4
WireConnection;40;0;39;1
WireConnection;40;1;39;3
WireConnection;41;0;40;0
WireConnection;41;1;42;0
WireConnection;43;0;44;0
WireConnection;46;0;47;0
WireConnection;46;1;45;0
WireConnection;48;0;43;0
WireConnection;52;0;9;0
WireConnection;52;1;53;0
WireConnection;44;0;41;0
WireConnection;44;1;46;0
WireConnection;50;0;51;0
WireConnection;50;1;49;0
WireConnection;53;0;50;0
WireConnection;18;0;22;0
WireConnection;21;0;23;0
WireConnection;19;0;21;0
WireConnection;19;1;20;0
WireConnection;22;0;13;1
WireConnection;22;1;19;0
WireConnection;14;0;12;0
WireConnection;14;1;18;0
WireConnection;7;0;2;0
ASEEND*/
//CHKSM=03205ECAF93C6DE92B708DC005B6CFC7E0604D40