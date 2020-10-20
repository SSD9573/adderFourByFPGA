module adderFourByFPGA(clk,rst,keyCfm,addNum,sum,segLeft,segRight); // sum为和,cin为输入,cout为输出,keyCfm为确认。


	input clk; // 时钟
	input rst; // 复位
	input keyCfm; // 确认键
	input [3:0] addNum; // 加数，由四路拨码开关给定
	// output cout; // 输出值
	// output [3:0] cin; // 进位值
	output [4:0] sum; // 求得的和
	output [8:0] segLeft; // 数码管(左侧)
	output [8:0] segRight; // 数码管(右侧)


	reg [3:0] addNumCopy; // 加数数据寄存器
	// reg [3:0] addNum2ndCopy; // 加数2数据寄存器
	reg [4:0] sumCopy; // 和数据寄存器
	reg [8:0] seg [2:0]; // 9位宽信号，用来存储数码管数字显示数据
	reg [8:0] segData [1:0]; // 数码管显示信号寄存器
	reg [1:0] cnt; // 计数器，计算是否符合显示和的条件
	reg lock; // 程序锁，检查是否需要继续运行


	wire cfmDBS; // 消抖后的确认按键脉冲
	// wire kPDBS; // 消抖后的求和按键脉冲


	initial
	begin
		addNumCopy <= 4'b0000; // 加数初始化为0
		sumCopy <= 4'b0000; // 和初始化为0
		seg[0] <= 8'h3f; // 4位二进制显示数字0
		seg[1] <= 8'h06; // 数字1
		seg[2] <= 8'h5b; // 2
		/*seg[3] <= 8'h4f; // 3
		seg[4] <= 8'h66; // 4
		seg[5] <= 8'h6d; // 5
		seg[6] <= 8'h7d; // 6
		seg[7] <= 8'h07; // 7
		seg[8] <= 8'h7f; // 8
		seg[9] <= 8'h6f; // 9
		seg[10] <= 8'h77;
		seg[11] <= 4'b1011;
		seg[12] <= 4'b1100;
		seg[13] <= 4'b1101;
		seg[14] <= 4'b1110;
		seg[15] <= 4'b1111;*/
		segData[0] <= seg[0]; // 数码管初始显示数字0
		segData[1] <= seg[2];
		cnt <= 2'b10; // 
	end

	always @ (posedge clk or negedge rst) // 
	begin
		if(!rst) // 
		begin
			addNumCopy <= 4'b0000; // 加数初始化为0
			sumCopy <= 4'b0000; // 和初始化为0
			segData[0] <= seg[0]; // 左边数码管显示0
			segData[1] <= seg[2]; // 右边数码管显示2
			cnt <= 2'b10; // 计数器初始化为2
			lock <= 1'b1; 
		end

		else if(cfmDBS && lock)
		begin
			if(cnt == 2'b10) // 若计数器为2,即仍未开始运算时
			begin
				segData[1] <= seg[1]; // 右边数码管显示1
				segData[0] <= seg[0]; // 左边数码管显示0
				addNumCopy = addNum; // 赋值加数
				sumCopy <= sumCopy + addNumCopy; // 运算
				cnt <= 2'b01; // 计数器值为1，即已经输入一位加数，代表若再次按下输入确认键，则输入第二个加数	
				/*
				if(addNumCopy < 4'b1010)
				begin
					segData[1] <= addNumCopy;
				end

				else if(addNumCopy >= 4'b1010)
				begin
					segData[0] <= 4'b0001; // 左边数码管显示1
					segData[1] <= addNumCopy - 4'b1010; // 右边数码管显示个位数
				end
				*/
			end

			else if(cnt == 2'b01) // 若计数器为1，即已经输入一位数时
			begin
				segData[1] <= seg[0]; // 右边数码管显示0
				segData[0] <= seg[0]; // 左边数码管显示0
				addNumCopy = addNum; // 赋值加数
				sumCopy <= sumCopy + addNumCopy; // 运算
				cnt <= 2'b00; // 计数器归零，代表若再次按下输入确认键，则直接输出结果
			end

			else if(cnt == 2'b00)
			begin
				// segData[1] <= seg[sumCopy % 2'd10]; // 右边数码管显示和个位数
				// segData[0] <= seg[sumCopy / 2'd10]; // 左边数码管显示和个位数
				lock <= 0; // 程序锁归零
			end
		end
	end

	// assign cin = ~addNumCopy;
	assign sum = ~sumCopy;
	assign segLeft = segData[0];
	assign segRight = segData[1];

	debounce keyCfmDBS // 消抖确认按键
	(
		.clk (clk),
		.rst (rst),
		.key (keyCfm),
		.key_pulse (cfmDBS)
	);

endmodule