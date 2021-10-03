// Copyright (c) 2012-2013 Ludvig Strigeus
// This program is GPL Licensed. See COPYING for the full license.

module video(
	input  clk,
	input [5:0] color,
	input [8:0] count_h,
	input [8:0] count_v,
	input pal_video,
	input overscan,
	input [3:0] palette,

	output reg   sync_h,
	output reg   sync_v,
	output [7:0] r,
	output [7:0] g,
	output [7:0] b
);

reg vidclk_en;
always @(posedge clk) vidclk_en <= ~vidclk_en;

reg [23:0] palettes[64*15];
initial begin
palettes = '{
	// Digital Prime (FBX) palette from FirebrandX
	'h696969, 'h00148F, 'h1E029B, 'h3F008A, 'h600060, 'h660017, 'h570D00, 'h451B00,
	'h243400, 'h004200, 'h004500, 'h003C1F, 'h00315C, 'h000000, 'h000000, 'h000000,
	'hAFAFAF, 'h0F51DD, 'h442FF3, 'h7220E2, 'hA319B3, 'hAE1C51, 'hA43400, 'h884D00,
	'h676D00, 'h208000, 'h008B00, 'h007F42, 'h006C97, 'h010101, 'h000000, 'h000000,
	'hFFFFFF, 'h65AAFF, 'h8C96FF, 'hB983FF, 'hDD6FFF, 'hEA6FBD, 'hEB8466, 'hDCA21F,
	'hBAB403, 'h7ECB07, 'h54D33E, 'h3CD284, 'h3EC7CC, 'h4B4B4B, 'h000000, 'h000000,
	'hFFFFFF, 'hBDE2FF, 'hCECFFF, 'hE6C2FF, 'hF6BCFF, 'hF9C2ED, 'hFACFC6, 'hF8DEAC,
	'hEEE9A1, 'hD0F59F, 'hBBF5AF, 'hB3F5CD, 'hB9EDF0, 'hB9B9B9, 'h000000, 'h000000,
	// Smooth palette from FirebrandX
	'h6A6D6A, 'h001380, 'h1E008A, 'h39007A, 'h550056, 'h5A0018, 'h4F1000, 'h3D1C00,
	'h253200, 'h003D00, 'h004000, 'h003924, 'h002E55, 'h000000, 'h000000, 'h000000,
	'hB9BCB9, 'h1850C7, 'h4B30E3, 'h7322D6, 'h951FA9, 'h9D285C, 'h983700, 'h7F4C00,
	'h5E6400, 'h227700, 'h027E02, 'h007645, 'h006E8A, 'h000000, 'h000000, 'h000000,
	'hFFFFFF, 'h68A6FF, 'h8C9CFF, 'hB586FF, 'hD975FD, 'hE377B9, 'hE58D68, 'hD49D29,
	'hB3AF0C, 'h7BC211, 'h55CA47, 'h46CB81, 'h47C1C5, 'h4A4D4A, 'h000000, 'h000000,
	'hFFFFFF, 'hCCEAFF, 'hDDDEFF, 'hECDAFF, 'hF8D7FE, 'hFCD6F5, 'hFDDBCF, 'hF9E7B5,
	'hF1F0AA, 'hDAFAA9, 'hC9FFBC, 'hC3FBD7, 'hC4F6F6, 'hBEC1BE, 'h000000, 'h000000,
	// NTSC UnsaturatedV6 palette
	//see: http://www.firebrandx.com/nespalette.html
	'h6B6B6B, 'h001E87, 'h1F0B96, 'h3B0C87, 'h590D61, 'h5E0528, 'h551100, 'h461B00,
	'h303200, 'h0A4800, 'h004E00, 'h004619, 'h003A58, 'h000000, 'h000000, 'h000000,
	'hB2B2B2, 'h1A53D1, 'h4835EE, 'h7123EC, 'h9A1EB7, 'hA51E62, 'hA52D19, 'h874B00,
	'h676900, 'h298400, 'h038B00, 'h008240, 'h007891, 'h000000, 'h000000, 'h000000,
	'hFFFFFF, 'h63ADFD, 'h908AFE, 'hB977FC, 'hE771FE, 'hF76FC9, 'hF5836A, 'hDD9C29,
	'hBDB807, 'h84D107, 'h5BDC3B, 'h48D77D, 'h48CCCE, 'h555555, 'h000000, 'h000000,
	'hFFFFFF, 'hC4E3FE, 'hD7D5FE, 'hE6CDFE, 'hF9CAFE, 'hFEC9F0, 'hFED1C7, 'hF7DCAC,
	'hE8E89C, 'hD1F29D, 'hBFF4B1, 'hB7F5CD, 'hB7F0EE, 'hBEBEBE, 'h000000, 'h000000,
	// FCEUX palette
	'h747474, 'h24188C, 'h0000A8, 'h44009C, 'h8C0074, 'hA80010, 'hA40000, 'h7C0800,
	'h402C00, 'h004400, 'h005000, 'h003C14, 'h183C5C, 'h000000, 'h000000, 'h000000,
	'hBCBCBC, 'h0070EC, 'h2038EC, 'h8000F0, 'hBC00BC, 'hE40058, 'hD82800, 'hC84C0C,
	'h887000, 'h009400, 'h00A800, 'h009038, 'h008088, 'h000000, 'h000000, 'h000000,
	'hFCFCFC, 'h3CBCFC, 'h5C94FC, 'hCC88FC, 'hF478FC, 'hFC74B4, 'hFC7460, 'hFC9838,
	'hF0BC3C, 'h80D010, 'h4CDC48, 'h58F898, 'h00E8D8, 'h787878, 'h000000, 'h000000,
	'hFCFCFC, 'hA8E4FC, 'hC4D4FC, 'hD4C8FC, 'hFCC4FC, 'hFCC4D8, 'hFCBCB0, 'hFCD8A8,
	'hFCE4A0, 'hE0FCA0, 'hA8F0BC, 'hB0FCCC, 'h9CFCF0, 'hC4C4C4, 'h000000, 'h000000,
	// NES Classic by FirebrandX
	'h616161, 'h000088, 'h1F0D99, 'h371379, 'h561260, 'h5D0010, 'h520E00, 'h3A2308,
	'h21350C, 'h0D410E, 'h174417, 'h003A1F, 'h002F57, 'h000000, 'h000000, 'h000000,
	'hAAAAAA, 'h0D4DC4, 'h4B24DE, 'h6912CF, 'h9014AD, 'h9D1C48, 'h923404, 'h735005,
	'h5D6913, 'h167A11, 'h138008, 'h127649, 'h1C6691, 'h000000, 'h000000, 'h000000,
	'hFCFCFC, 'h639AFC, 'h8A7EFC, 'hB06AFC, 'hDD6DF2, 'hE771AB, 'hE38658, 'hCC9E22,
	'hA8B100, 'h72C100, 'h5ACD4E, 'h34C28E, 'h4FBECE, 'h424242, 'h000000, 'h000000,
	'hFCFCFC, 'hBED4FC, 'hCACAFC, 'hD9C4FC, 'hECC1FC, 'hFAC3E7, 'hF7CEC3, 'hE2CDA7,
	'hDADB9C, 'hC8E39E, 'hBFE5B8, 'hB2EBC8, 'hB7E5EB, 'hACACAC, 'h000000, 'h000000,
	// Composite Direct by FirebrandX
	'h656565, 'h00127D, 'h18008E, 'h360082, 'h56005D, 'h5A0018, 'h4F0500, 'h381900,
	'h1D3100, 'h003D00, 'h004100, 'h003B17, 'h002E55, 'h000000, 'h000000, 'h000000,
	'hAFAFAF, 'h194EC8, 'h472FE3, 'h6B1FD7, 'h931BAE, 'h9E1A5E, 'h993200, 'h7B4B00,
	'h5B6700, 'h267A00, 'h008200, 'h007A3E, 'h006E8A, 'h000000, 'h000000, 'h000000,
	'hFFFFFF, 'h64A9FF, 'h8E89FF, 'hB676FF, 'hE06FFF, 'hEF6CC4, 'hF0806A, 'hD8982C,
	'hB9B40A, 'h83CB0C, 'h5BD63F, 'h4AD17E, 'h4DC7CB, 'h4C4C4C, 'h000000, 'h000000,
	'hFFFFFF, 'hC7E5FF, 'hD9D9FF, 'hE9D1FF, 'hF9CEFF, 'hFFCCF1, 'hFFD4CB, 'hF8DFB1,
	'hEDEAA4, 'hD6F4A4, 'hC5F8B8, 'hBEF6D3, 'hBFF1F1, 'hB9B9B9, 'h000000, 'h000000,
	// PC-10 by FirebrandX
	'h6D6D6D, 'h002492, 'h0000DB, 'h6D49DB, 'h92006D, 'hB6006D, 'hB62400, 'h924900,
	'h6D4900, 'h244900, 'h006D24, 'h009200, 'h004949, 'h000000, 'h000000, 'h000000,
	'hB6B6B6, 'h006DDB, 'h0049FF, 'h9200FF, 'hB600FF, 'hFF0092, 'hFF0000, 'hDB6D00,
	'h926D00, 'h249200, 'h009200, 'h00B66D, 'h009292, 'h242424, 'h000000, 'h000000,
	'hFFFFFF, 'h6DB6FF, 'h9292FF, 'hDB6DFF, 'hFF00FF, 'hFF6DFF, 'hFF9200, 'hFFB600,
	'hDBDB00, 'h6DDB00, 'h00FF00, 'h49FFDB, 'h00FFFF, 'h494949, 'h000000, 'h000000,
	'hFFFFFF, 'hB6DBFF, 'hDBB6FF, 'hFFB6FF, 'hFF92FF, 'hFFB6B6, 'hFFDB92, 'hFFFF49,
	'hFFFF6D, 'hB6FF49, 'h92FF6D, 'h49FFDB, 'h92DBFF, 'h929292, 'h000000, 'h000000,
	// PVM by FirebrandX
	'h696E69, 'h001774, 'h1E0087, 'h340073, 'h560057, 'h5E0013, 'h531A00, 'h3B2400,
	'h243000, 'h063A00, 'h003F00, 'h003B1E, 'h003050, 'h000000, 'h000000, 'h000000,
	'hB9BEB9, 'h1453B9, 'h4D2CDA, 'h671EDE, 'h98189C, 'h9D2344, 'hA03E00, 'h8D5500,
	'h656D00, 'h2C7900, 'h008100, 'h007D42, 'h00788A, 'h000000, 'h000000, 'h000000,
	'hFFFFFF, 'h69A8FF, 'h9691FF, 'hB28AFA, 'hEA7DFA, 'hF37BC7, 'hF18F6C, 'hE6AD27,
	'hD7C805, 'h90DF07, 'h64E53C, 'h45E27D, 'h48D5D9, 'h4B504B, 'h000000, 'h000000,
	'hFFFFFF, 'hD2EAFF, 'hE2E2FF, 'hE9D8FF, 'hF5D2FF, 'hF8D9EA, 'hFADEB9, 'hF9E89B,
	'hF3F28C, 'hD3FA91, 'hB8FCA8, 'hAEFACA, 'hCAF3F3, 'hBEC3BE, 'h000000, 'h000000,
	// Wavebeam by NakedArthur
	'h6B6B6B, 'h001B88, 'h21009A, 'h40008C, 'h600067, 'h64001E, 'h590800, 'h481600,
	'h283600, 'h004500, 'h004908, 'h00421D, 'h003659, 'h000000, 'h000000, 'h000000,
	'hB4B4B4, 'h1555D3, 'h4337EF, 'h7425DF, 'h9C19B9, 'hAC0F64, 'hAA2C00, 'h8A4B00,
	'h666B00, 'h218300, 'h008A00, 'h008144, 'h007691, 'h000000, 'h000000, 'h000000,
	'hFFFFFF, 'h63B2FF, 'h7C9CFF, 'hC07DFE, 'hE977FF, 'hF572CD, 'hF4886B, 'hDDA029,
	'hBDBD0A, 'h89D20E, 'h5CDE3E, 'h4BD886, 'h4DCFD2, 'h525252, 'h000000, 'h000000,
	'hFFFFFF, 'hBCDFFF, 'hD2D2FF, 'hE1C8FF, 'hEFC7FF, 'hFFC3E1, 'hFFCAC6, 'hF2DAAD,
	'hEBE3A0, 'hD2EDA2, 'hBCF4B4, 'hB5F1CE, 'hB6ECF1, 'hBFBFBF, 'h000000, 'h000000,
	// Reality C by Squire
	'h6C6C6C, 'h00268E, 'h0000A8, 'h400094, 'h700070, 'h780040, 'h700000, 'h621600,
	'h442400, 'h343400, 'h005000, 'h004444, 'h004060, 'h000000, 'h101010, 'h101010,
	'hBABABA, 'h205CDC, 'h3838FF, 'h8020F0, 'hC000C0, 'hD01474, 'hD02020, 'hAC4014,
	'h7C5400, 'h586400, 'h008800, 'h007468, 'h00749C, 'h202020, 'h101010, 'h101010,
	'hFFFFFF, 'h4CA0FF, 'h8888FF, 'hC06CFF, 'hFF50FF, 'hFF64B8, 'hFF7878, 'hFF9638,
	'hDBAB00, 'hA2CA20, 'h4ADC4A, 'h2CCCA4, 'h1CC2EA, 'h585858, 'h101010, 'h101010,
	'hFFFFFF, 'hB0D4FF, 'hC4C4FF, 'hE8B8FF, 'hFFB0FF, 'hFFB8E8, 'hFFC4C4, 'hFFD4A8,
	'hFFE890, 'hF0F4A4, 'hC0FFC0, 'hACF4F0, 'hA0E8FF, 'hC2C2C2, 'h202020, 'h101010,
	// Sony CXA by FirebrandX
	'h585858, 'h00238C, 'h00139B, 'h2D0585, 'h5D0052, 'h7A0017, 'h7A0800, 'h5F1800,
	'h352A00, 'h093900, 'h003F00, 'h003C22, 'h00325D, 'h000000, 'h000000, 'h000000,
	'hA1A1A1, 'h0053EE, 'h153CFE, 'h6028E4, 'hA91D98, 'hD41E41, 'hD22C00, 'hAA4400,
	'h6C5E00, 'h2D7300, 'h007D06, 'h007852, 'h0069A9, 'h000000, 'h000000, 'h000000,
	'hFFFFFF, 'h1FA5FE, 'h5E89FE, 'hB572FE, 'hFE65F6, 'hFE6790, 'hFE773C, 'hFE9308,
	'hC4B200, 'h79CA10, 'h3AD54A, 'h11D1A4, 'h06BFFE, 'h424242, 'h000000, 'h000000,
	'hFFFFFF, 'hA0D9FE, 'hBDCCFE, 'hE1C2FE, 'hFEBCFB, 'hFEBDD0, 'hFEC5A9, 'hFED18E,
	'hE9DE86, 'hC7E992, 'hA8EEB0, 'h95ECD9, 'h91E4FE, 'hACACAC, 'h000000, 'h000000,
	// YUV from Nestopia
	'h666666, 'h002A88, 'h1412A7, 'h3B00A4, 'h5C007E, 'h6E0040, 'h6C0700, 'h561D00,
	'h333500, 'h0C4800, 'h005200, 'h004F08, 'h00404D, 'h000000, 'h000000, 'h000000,
	'hADADAD, 'h155FD9, 'h4240FF, 'h7527FE, 'hA01ACC, 'hB71E7B, 'hB53120, 'h994E00,
	'h6B6D00, 'h388700, 'h0D9300, 'h008F32, 'h007C8D, 'h000000, 'h000000, 'h000000,
	'hFFFFFF, 'h64B0FF, 'h9290FF, 'hC676FF, 'hF26AFF, 'hFF6ECC, 'hFF8170, 'hEA9E22,
	'hBCBE00, 'h88D800, 'h5CE430, 'h45E082, 'h48CDDE, 'h4F4F4F, 'h000000, 'h000000,
	'hFFFFFF, 'hC0DFFF, 'hD3D2FF, 'hE8C8FF, 'hFAC2FF, 'hFFC4EA, 'hFFCCC5, 'hF7D8A5,
	'hE4E594, 'hCFEF96, 'hBDF4AB, 'hB3F3CC, 'hB5EBF2, 'hB8B8B8, 'h000000, 'h000000,
	// Greyscale
	'h747474, 'h3E3E3E, 'h343434, 'h2E2E2E, 'h393939, 'h353535, 'h303030, 'h161616,
	'h1F1F1F, 'h3E3E3E, 'h444444, 'h3E3E3E, 'h383838, 'h000000, 'h0A0A0A, 'h0A0A0A,
	'hB2B2B2, 'h7B7B7B, 'h696969, 'h636363, 'h707070, 'h6D6D6D, 'h6B6B6B, 'h666666,
	'h727272, 'h7D7D7D, 'h898989, 'h838383, 'h7E7E7E, 'h353535, 'h0A0A0A, 'h0A0A0A,
	'hF1F1F1, 'hBEBEBE, 'hA1A1A1, 'h959595, 'hA1A1A1, 'h9E9E9E, 'hA2A2A2, 'hAAAAAA,
	'hB5B5B5, 'hBDBDBD, 'hC8C8C8, 'hC6C6C6, 'hC4C4C4, 'h606060, 'h0A0A0A, 'h0A0A0A,
	'hF1F1F1, 'hE9E9E9, 'hD9D9D9, 'hCCCCCC, 'hCFCFCF, 'hCDCDCD, 'hCFCFCF, 'hD3D3D3,
	'hD9D9D9, 'hDBDBDB, 'hDEDEDE, 'hDDDDDD, 'hDDDDDD, 'hBABABA, 'h0A0A0A, 'h0A0A0A,
	// Rockman9 Palette
	'h707070, 'h0000A8, 'h201888, 'h400098, 'h880070, 'hA80010, 'hA00000, 'h780800,
	'h402800, 'h004000, 'h005000, 'h003810, 'h183858, 'h000000, 'h000000, 'h000000,
	'hB8B8B8, 'h0070E8, 'h2038E8, 'h8000F0, 'hB800B8, 'hE00058, 'hD82800, 'hC84808,
	'h887000, 'h009000, 'h00A800, 'h009038, 'h008088, 'h000000, 'h000000, 'h000000,
	'hF8F8F8, 'h38B8F8, 'h5890F8, 'hA088F8, 'hF078F8, 'hF870B0, 'hF87060, 'hF89838,
	'hF0B838, 'h80D010, 'h48D848, 'h58F898, 'h00E8D8, 'h505050, 'h000000, 'h000000,
	'hF8F8F8, 'hA8E0F8, 'hC0D0F8, 'hD0C8F8, 'hF8C0F8, 'hF8C0D8, 'hF8B8B0, 'hF8D8A8,
	'hF8E0A0, 'hE0F8A0, 'hA8F0B8, 'hB0F8C8, 'h98F8F0, 'h989898, 'h000000, 'h000000,
	// Nintendulator NTSC
	'h656565, 'h002B9B, 'h110EC0, 'h3F00BC, 'h66008F, 'h7B0045, 'h790100, 'h601C00,
	'h363800, 'h084F00, 'h005A00, 'h005702, 'h004555, 'h000000, 'h000000, 'h000000,
	'hAEAEAE, 'h0761F5, 'h3E3BFF, 'h7C1DFF, 'hAF0EE5, 'hCB1383, 'hC82A15, 'hA74D00,
	'h6F7200, 'h379100, 'h009F00, 'h009B2A, 'h008498, 'h000000, 'h000000, 'h000000,
	'hFFFFFF, 'h56B1FF, 'h8E8BFF, 'hCC6CFF, 'hFF5DFF, 'hFF62D4, 'hFF7964, 'hF89D06,
	'hC0C300, 'h81E200, 'h4DF116, 'h30EC7A, 'h34D5EA, 'h4E4E4E, 'h000000, 'h000000,
	'hFFFFFF, 'hBADFFF, 'hD1D0FF, 'hEBC3FF, 'hFFBDFF, 'hFFBFEE, 'hFFC8C0, 'hFCD799,
	'hEFE784, 'hCCF387, 'hB6F9A0, 'hAAF8C9, 'hACEEF7, 'hB7B7B7, 'h000000, 'h000000
};
end

reg [23:0] palette_out;
always @(posedge clk) begin
	palette_out <= palettes[{palette, color}];
end
wire [23:0] pixel = palette_out;

// Horizontal and vertical counters
reg [9:0] h, v;
wire hpicture  = (h < 512);             // 512 lines of picture
wire hend = (h == 681);                 // End of line, 682 pixels.
wire vpicture = (v < 240);              // 240 lines of picture
wire vend = (v == (pal_video ? 311 : 261)); // End of picture, 262/312 lines.

reg [8:0] old_count_v;
wire sync_frame = (old_count_v == 9'd511) && (count_v == 9'd0);
always @(posedge clk) begin
	if (vidclk_en) begin
		h <= (hend || sync_frame) ? 10'd0 : h + 10'd1;
		if(sync_frame) v <= 0;
		else if (hend) v <= vend ? 10'd0 : v + 10'd1;

		old_count_v <= count_v;
	end
end

wire [23:0] pixel_v = (!hpicture || !vpicture) ? 24'd0 : pixel;

// display overlay to hide overscan area
// based on Mario3, DoubleDragon2, Shadow of the Ninja
wire ol = overscan && ( (h > 512-16) ||
								(h < 20) ||
								(v < 6 ) ||
								(v > (240-10))
							  );

assign      b = ol ? {7'b0, pixel_v[7:7]}   : pixel_v[7:0];
assign      g = ol ? {7'b0, pixel_v[15:15]} : pixel_v[15:8];
assign      r = ol ? {7'b0, pixel_v[23:23]} : pixel_v[23:16];

always @(posedge clk) begin
	if (vidclk_en) begin
		if (h == 556) begin
			sync_h <= 1;
			sync_v <= (v >= (pal_video ? 270 : 243) && (v < ((pal_video ? 270 : 243) + 3)));
		end
		if (h == 606) sync_h <= 0;
	end
end

endmodule
