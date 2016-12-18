unit CH341DLL;
{$mode delphi}
interface
// 2004.05.28, 2004.10.20, 2005.01.08, 2005.03.25
//****************************************
//**  Copyright  (C)  W.ch  1999-2005   **
//**  Web:  http://www.winchiphead.com  **
//****************************************
//**  DLL for USB interface chip CH341  **
//**  C, VC5.0                          **
//****************************************
//
// USB总线接口芯片CH341并口应用层接口库 V1.5
// 南京沁恒电子有限公司  作者: W.ch 2005.03
// CH341-DLL  V1.5
// 运行环境: Windows 98/ME, Windows 2000/XP
// support USB chip: CH341, CH341A
// USB => Parallel, I2C, SPI, JTAG ...
// Частичный перевод TIFA
uses SysUtils;
const
     FILE_DEVICE_UNKNOWN = $22;
     FILE_ANY_ACCESS = 0;
     METHOD_BUFFERED = 0;
     mCH341_PACKET_LENGTH = 32;			// CH341支持的数据包的长度
     mCH341_PKT_LEN_SHORT = 8 ;			// CH341支持的短数据包的长度



// WIN32应用层接口命令
//     IOCTL_CH341_COMMAND		( FILE_DEVICE_UNKNOWN << 16 | FILE_ANY_ACCESS << 14 | 0x0f34 << 2 | METHOD_BUFFERED )	// 专用接口
//     mWIN32_COMMAND_HEAD		mOFFSET( mWIN32_COMMAND, mBuffer )	// WIN32命令接口的头长度
     mCH341_MAX_NUMBER =	16;			// 最多同时连接的CH341数
     mMAX_BUFFER_LENGTH	=$1000;		// 数据缓冲区最大长度4096
//     mMAX_COMMAND_LENGTH		( mWIN32_COMMAND_HEAD + mMAX_BUFFER_LENGTH )	// 最大数据长度加上命令结构头的长度
     mDEFAULT_BUFFER_LEN=$0400;		// 数据缓冲区默认长度1024
//     mDEFAULT_COMMAND_LEN	( mWIN32_COMMAND_HEAD + mDEFAULT_BUFFER_LEN )	// 默认数据长度加上命令结构头的长度

// CH341端点地址
     mCH341_ENDP_INTER_UP=$81 ;		// CH341的中断数据上传端点的地址
     mCH341_ENDP_INTER_DOWN=$01;		// CH341的中断数据下传端点的地址
     mCH341_ENDP_DATA_UP=$82  ;		// CH341的数据块上传端点的地址
     mCH341_ENDP_DATA_DOWN=$02 ;		// CH341的数据块下传端点的地址

// 设备层接口提供的管道操作命令
     mPipeDeviceCtrl=$00000004;	// CH341的综合控制管道
     mPipeInterUp=$00000005  ;	// CH341的中断数据上传管道
     mPipeDataUp =$00000006  ;	// CH341的数据块上传管道
     mPipeDataDown=$00000007 ;	// CH341的数据块下传管道

// 应用层接口的功能代码
     mFuncNoOperation=$00000000;	// 无操作
     mFuncGetVersion =$00000001;	// 获取驱动程序版本号
     mFuncGetConfig  =$00000002	;// 获取USB设备配置描述符
     mFuncSetTimeout =$00000009	;// 设置USB通讯超时
     mFuncSetExclusive=$0000000b;	// 设置独占使用
     mFuncResetDevice =$0000000c ;	// 复位USB设备
     mFuncResetPipe  	=$0000000d ;	// 复位USB管道
     mFuncAbortPipe			=$0000000e;	// 取消USB管道的数据请求

// CH341并口专用的功能代码
     mFuncSetParaMode		=$0000000f  ;	// 设置并口模式
     mFuncReadData0			=$00000010 ;	// 从并口读取数据块0
     mFuncReadData1			=$00000011 ;	// 从并口读取数据块1
     mFuncWriteData0			=$00000012 ;	// 向并口写入数据块0
     mFuncWriteData1			=$00000013  ;	// 向并口写入数据块1
     mFuncWriteRead			=$00000014  ;	// 先输出再输入


// USB设备标准请求代码
     mUSB_CLR_FEATURE		=$01;
     mUSB_SET_FEATURE		=$03 ;
     mUSB_GET_STATUS			=$00 ;
     mUSB_SET_ADDRESS		=$05      ;
     mUSB_GET_DESCR			=$06   ;
     mUSB_SET_DESCR			=$07   ;
     mUSB_GET_CONFIG			=$08   ;
     mUSB_SET_CONFIG			=$09    ;
     mUSB_GET_INTERF			=$0a    ;
     mUSB_SET_INTERF			=$0b    ;
     mUSB_SYNC_FRAME			=$0c    ;

// CH341控制传输的厂商专用请求类型
     mCH341_VENDOR_READ		=$C0	 ;	// 通过控制传输实现的CH341厂商专用读操作
     mCH341_VENDOR_WRITE		=$40 ;		// 通过控制传输实现的CH341厂商专用写操作

// CH341控制传输的厂商专用请求代码
     mCH341_PARA_INIT		=$B1	;	// 初始化并口
     mCH341_I2C_STATUS		=$52	;	// 获取I2C接口的状态
     mCH341_I2C_COMMAND		=$53	 ;	// 发出I2C接口的命令

// CH341并口操作命令代码
     mCH341_PARA_CMD_R0		=$AC ;		// 从并口读数据0
     mCH341_PARA_CMD_R1		=$AD  ;		// 从并口读数据1
     mCH341_PARA_CMD_W0		=$A6  ;		// 向并口写数据0
     mCH341_PARA_CMD_W1		=$A7  ;		// 向并口写数据1
     mCH341_PARA_CMD_STS		=$A0  ;		// 获取并口状态

// CH341A并口操作命令代码
     mCH341A_CMD_SET_OUTPUT	=$A1;		// 设置并口输出
     mCH341A_CMD_IO_ADDR		=$A2 ;		// MEM带地址读写/输入输出,从次字节开始为命令流
     mCH341A_CMD_SPI_STREAM	=$A8  ;		// SPI接口的命令包,从次字节开始为数据流
     mCH341A_CMD_SIO_STREAM	=$A9  ;		// SIO接口的命令包,从次字节开始为数据流
     mCH341A_CMD_I2C_STREAM	=$AA  ;		// I2C接口的命令包,从次字节开始为I2C命令流
     mCH341A_CMD_UIO_STREAM	=$AB  ;		// UIO接口的命令包,从次字节开始为命令流

// CH341A控制传输的厂商专用请求代码
     mCH341A_BUF_CLEAR		=$B2 ;		// 清除未完成的数据
     mCH341A_I2C_CMD_X		=$54  ;		// 发出I2C接口的命令,立即执行
     mCH341A_DELAY_MS		=$5E  ;		// 以亳秒为单位延时指定时间
     mCH341A_GET_VER			=$5F   ;		// 获取芯片版本

     mCH341_EPP_IO_MAX	 =	( mCH341_PACKET_LENGTH - 1 )  ;	// CH341在EPP/MEM方式下单次读写数据块的最大长度
     mCH341A_EPP_IO_MAX		=$FF  ;		// CH341A在EPP/MEM方式下单次读写数据块的最大长度

     mCH341A_CMD_IO_ADDR_W	=$00   ;		// MEM带地址读写/输入输出的命令流:写数据,位6-位0为地址,下一个字节为待写数据
     mCH341A_CMD_IO_ADDR_R	=$80   ;		// MEM带地址读写/输入输出的命令流:读数据,位6-位0为地址,读出数据一起返回

     mCH341A_CMD_I2C_STM_STA	=$74	;	// I2C接口的命令流:产生起始位
     mCH341A_CMD_I2C_STM_STO	=$75   ;		// I2C接口的命令流:产生停止位
     mCH341A_CMD_I2C_STM_OUT	=$80	;	// I2C接口的命令流:输出数据,位5-位0为长度,后续字节为数据,0长度则只发送一个字节并返回应答
     mCH341A_CMD_I2C_STM_IN	=$C0	;	// I2C接口的命令流:输入数据,位5-位0为长度,0长度则只接收一个字节并发送无应答
//     mCH341A_CMD_I2C_STM_MAX   =	( min( =$3F, mCH341_PACKET_LENGTH ) );	// I2C接口的命令流单个命令输入输出数据的最大长度
     mCH341A_CMD_I2C_STM_SET	=$60  ;		// I2C接口的命令流:设置参数,位2=SPI的I/O数(0=单入单出,1=双入双出),位1位0=I2C速度(00=低速,01=标准,10=快速,11=高速)
     mCH341A_CMD_I2C_STM_US	=$40	;	// I2C接口的命令流:以微秒为单位延时,位3-位0为延时值
     mCH341A_CMD_I2C_STM_MS	=$50 ;		// I2C接口的命令流:以亳秒为单位延时,位3-位0为延时值
     mCH341A_CMD_I2C_STM_DLY	=$0F  ;		// I2C接口的命令流单个命令延时的最大值
     mCH341A_CMD_I2C_STM_END	=$00  ;		// I2C接口的命令流:命令包提前结束

     mCH341A_CMD_UIO_STM_IN	=$00  ;		// UIO接口的命令流:输入数据D7-D0
     mCH341A_CMD_UIO_STM_DIR	=$40  ;		// UIO接口的命令流:设定I/O方向D5-D0,位5-位0为方向数据
     mCH341A_CMD_UIO_STM_OUT	=$80 ;		// UIO接口的命令流:输出数据D5-D0,位5-位0为数据
     mCH341A_CMD_UIO_STM_US	=$C0   ;		// UIO接口的命令流:以微秒为单位延时,位5-位0为延时值
     mCH341A_CMD_UIO_STM_END	=$20	;	// UIO接口的命令流:命令包提前结束


// CH341并口工作模式
     mCH341_PARA_MODE_EPP	=$00 ;		// CH341并口工作模式为EPP方式
     mCH341_PARA_MODE_EPP17	=$00 ;		// CH341A并口工作模式为EPP方式V1.7
     mCH341_PARA_MODE_EPP19	=$01 ;		// CH341A并口工作模式为EPP方式V1.9
     mCH341_PARA_MODE_MEM	=$02 ;		// CH341并口工作模式为MEM方式


// 直接输入的状态信号的位定义
     mStateBitERR			=$00000100 ;	// 只读,ERR#引脚输入状态,1:高电平,0:低电平
     mStateBitPEMP			=$00000200 ;	// 只读,PEMP引脚输入状态,1:高电平,0:低电平
     mStateBitINT			=$00000400 ;	// 只读,INT#引脚输入状态,1:高电平,0:低电平
     mStateBitSLCT			=$00000800 ;	// 只读,SLCT引脚输入状态,1:高电平,0:低电平
     mStateBitSDA			=$00800000 ;	// 只读,SDA引脚输入状态,1:高电平,0:低电平

type
  PVOID = Pointer;
  PULONG=pcardinal;

Type
        mUspValue=record
        mUspValueLow : Byte;
        mUspValueHigh : Byte;
End;
Type
        mUspIndex=record
        mUspIndexLow : Byte;
        mUspIndexHigh  : Byte;
End ;
Type
    USB_SETUP_PKT=record
    mUspReqType : Byte;
    mUspRequest : Byte;
    mUspValue : mUspValue;
    mUspIndex : mUspIndex;
    mLength : Integer;
End ;
Type
   WIN32_COMMAND=record               //定义WIN32命令接口结构
   mFunction : cardinal;              //输入时指定功能代码或者管道号
                                      //输出时返回操作状态
   mLength : cardinal;                //存取长度,返回后续数据的长度
   mBuffer:array[0..(mCH341_PACKET_LENGTH-1)] of Byte;         //数据缓冲区,长度为0至255B                                           '数据缓冲区,长度为0至255B
End ;

Type mPWIN32_COMMAND=^WIN32_COMMAND;

var
   mUSB_SETUP_PKT :USB_SETUP_PKT;
   mWIN32_COMMAND : WIN32_COMMAND;

type  mPCH341_INT_ROUTINE=Procedure (  // 中断服务程序
      iStatus:cardinal );stdcall;      // 中断状态数据,见下行
      // 位7-位0对应CH341的D7-D0引脚
      // 位8对应CH341的ERR#引脚, 位9对应CH341的PEMP引脚, 位10对应CH341的INT#引脚, 位11对应CH341的SLCT引脚

Function CH341OpenDevice(    // Возвращает идентификатор или ошибку(отрицательное)
    iIndex :cardinal):integer ;Stdcall; external 'CH341DLL.DLL' ;// номер устройства, 0 соответствует первому

procedure CH341CloseDevice(    // 关闭CH341设备
                   iIndex :cardinal) ;Stdcall; external 'CH341DLL.DLL';// номер устройства


Function CH341GetVersion( ):cardinal;Stdcall; external 'CH341DLL.DLL';  // Возврощает версию DLL


Function CH341DriverCommand(  // 直接传递命令给驱动程序,出错则返回0,否则返回数据长度
	iIndex:cardinal;  // 指定CH341设备序号,V1.6以上DLL也可以是设备打开后的句柄
	ioCommand:mPWIN32_COMMAND):cardinal;Stdcall; external 'CH341DLL.DLL';  // 命令结构的指针
// 该程序在调用后返回数据长度,并且仍然返回命令结构,如果是读操作,则数据返回在命令结构中,
// 返回的数据长度在操作失败时为0,操作成功时为整个命令结构的长度,例如读一个字节,则返回mWIN32_COMMAND_HEAD+1,
// 命令结构在调用前,分别提供:管道号或者命令功能代码,存取数据的长度(可选),数据(可选)
// 命令结构在调用后,分别返回:操作状态代码,后续数据的长度(可选),
//   操作状态代码是由WINDOWS定义的代码,可以参考NTSTATUS.H,
//   后续数据的长度是指读操作返回的数据长度,数据存放在随后的缓冲区中,对于写操作一般为0


Function CH341GetDrvVersion( ):cardinal;Stdcall; external 'CH341DLL.DLL';  // Возвращает версию драйвера, или 0 при ошибке


Function CH341ResetDevice(  // 复位USB设备
	iIndex:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指定CH341设备序号


Function CH341GetDeviceDescr(  // 读取设备描述符
	iIndex:cardinal;  // 指定CH341设备序号
	oBuffer:PVOID;  // 指向一个足够大的缓冲区,用于保存描述符
	ioLength:PULONG ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指向长度单元,输入时为准备读取的长度,返回后为实际读取的长度


Function CH341GetConfigDescr(  // 读取配置描述符
	iIndex:cardinal;  // 指定CH341设备序号
	oBuffer:PVOID;  // 指向一个足够大的缓冲区,用于保存描述符
	ioLength:PULONG ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指向长度单元,输入时为准备读取的长度,返回后为实际读取的长度


Function CH341SetIntRoutine(  // 设定中断服务程序
	iIndex:cardinal;  // 指定CH341设备序号
	iIntRoutine:mPCH341_INT_ROUTINE ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指定中断服务程序,为NULL则取消中断服务,否则在中断时调用该程序


Function CH341ReadInter(  // 读取中断数据
	iIndex:cardinal;  // 指定CH341设备序号
	iStatus:PULONG ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指向一个双字单元,用于保存读取的中断状态数据,见下行
// 位7-位0对应CH341的D7-D0引脚
// 位8对应CH341的ERR#引脚, 位9对应CH341的PEMP引脚, 位10对应CH341的INT#引脚, 位11对应CH341的SLCT引脚


Function CH341AbortInter(  // 放弃中断数据读操作
	iIndex:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指定CH341设备序号


Function CH341SetParaMode(  // 设置并口模式
	iIndex:cardinal;  // 指定CH341设备序号
	iMode:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指定并口模式: 0为EPP模式/EPP模式V1.7, 1为EPP模式V1.9, 2为MEM模式

Function CH341InitParallel(  // 复位并初始化并口,RST#输出低电平脉冲
	iIndex:cardinal;  // 指定CH341设备序号
	iMode:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指定并口模式: 0为EPP模式/EPP模式V1.7, 1为EPP模式V1.9, 2为MEM模式, >= 0x00000100 保持当前模式


Function CH341ReadData0(  // 从0#端口读取数据块
	iIndex:cardinal;  // 指定CH341设备序号
	oBuffer:PVOID;  // 指向一个足够大的缓冲区,用于保存读取的数据
	ioLength:PULONG ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指向长度单元,输入时为准备读取的长度,返回后为实际读取的长度

Function CH341ReadData1(  // 从1#端口读取数据块
	iIndex:cardinal;  // 指定CH341设备序号
	oBuffer:PVOID;  // 指向一个足够大的缓冲区,用于保存读取的数据
	ioLength:PULONG ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指向长度单元,输入时为准备读取的长度,返回后为实际读取的长度

Function CH341AbortRead(  // 放弃数据块读操作
	iIndex:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指定CH341设备序号


Function CH341WriteData0(  // 向0#端口写出数据块
	iIndex:cardinal;  // 指定CH341设备序号
	iBuffer:PVOID;  // 指向一个缓冲区,放置准备写出的数据
	ioLength:PULONG ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指向长度单元,输入时为准备写出的长度,返回后为实际写出的长度


Function CH341WriteData1(  // 向1#端口写出数据块
	iIndex:cardinal;  // 指定CH341设备序号
	iBuffer:PVOID;  // 指向一个缓冲区,放置准备写出的数据
	ioLength:PULONG ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指向长度单元,输入时为准备写出的长度,返回后为实际写出的长度


Function CH341AbortWrite(  // 放弃数据块写操作
	iIndex:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指定CH341设备序号


Function CH341GetStatus(  // Получить состояние входный пинов
	iIndex:cardinal;  // номер устройства
	iStatus:PULONG ):boolean;Stdcall; external 'CH341DLL.DLL';  // DWORD с данными о состоянии
// Бит 7-0 соответствует D7-D0
// Бит 8 ERR#, 9 PEMP, 10 INT#, 11 SLCT, 23 SDA
// Бит 13 BUSY/WAIT#, 14 AUTOFD#/DATAS#,15 SLCTIN#/ADDRS#


Function CH341ReadI2C(  // 从I2C接口读取一个字节数据
	iIndex:cardinal;  // 指定CH341设备序号
	iDevice:byte;  // 低7位指定I2C设备地址
	iAddr:byte;  // 指定数据单元的地址
	oByte:Pbytearray ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指向一个字节单元,用于保存读取的字节数据


Function CH341WriteI2C(  // 向I2C接口写入一个字节数据
	iIndex:cardinal;  // 指定CH341设备序号
	iDevice:byte;  // 低7位指定I2C设备地址
	iAddr:byte;  // 指定数据单元的地址
	iByte:byte ):boolean;Stdcall; external 'CH341DLL.DLL';  // 待写入的字节数据


Function CH341EppReadData(  // EPP方式读数据: WR#=1, DS#=0, AS#=1, D0-D7=input
	iIndex:cardinal;  // 指定CH341设备序号
	oBuffer:PVOID;  // 指向一个足够大的缓冲区,用于保存读取的数据
	ioLength:PULONG ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指向长度单元,输入时为准备读取的长度,返回后为实际读取的长度


Function CH341EppReadAddr(  // EPP方式读地址: WR#=1, DS#=1, AS#=0, D0-D7=input
	iIndex:cardinal;  // 指定CH341设备序号
	oBuffer:pvoid;  // 指向一个足够大的缓冲区,用于保存读取的地址数据
	ioLength:PULONG ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指向长度单元,输入时为准备读取的长度,返回后为实际读取的长度


Function CH341EppWriteData(  // EPP方式写数据: WR#=0, DS#=0, AS#=1, D0-D7=output
	iIndex:cardinal;  // 指定CH341设备序号
	iBuffer:pvoid;  // 指向一个缓冲区,放置准备写出的数据
	ioLength:PULONG ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指向长度单元,输入时为准备写出的长度,返回后为实际写出的长度


Function CH341EppWriteAddr(  // EPP方式写地址: WR#=0, DS#=1, AS#=0, D0-D7=output
	iIndex:cardinal;  // 指定CH341设备序号
	iBuffer:PVOID;  // 指向一个缓冲区,放置准备写出的地址数据
	ioLength:PULONG ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指向长度单元,输入时为准备写出的长度,返回后为实际写出的长度


Function CH341EppSetAddr(  // EPP方式设置地址: WR#=0, DS#=1, AS#=0, D0-D7=output
	iIndex:cardinal;  // 指定CH341设备序号
	iAddr:byte ):boolean;Stdcall; external 'CH341DLL.DLL';  // 指定EPP地址



Function CH341MemReadAddr0(  // MEM方式读地址0: WR#=1, DS#/RD#=0, AS#/ADDR=0, D0-D7=input
	iIndex:cardinal;  // 指定CH341设备序号
	oBuffer:pvoid;  // 指向一个足够大的缓冲区,用于保存从地址0读取的数据
	ioLength:PULONG ):boolean;Stdcall; external 'CH341DLL.DLL' ; // 指向长度单元,输入时为准备读取的长度,返回后为实际读取的长度


Function CH341MemReadAddr1(  // MEM方式读地址1: WR#=1, DS#/RD#=0, AS#/ADDR=1, D0-D7=input
	iIndex:cardinal;  // 指定CH341设备序号
	oBuffer:pvoid;  // 指向一个足够大的缓冲区,用于保存从地址1读取的数据
	ioLength:PULONG ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 指向长度单元,输入时为准备读取的长度,返回后为实际读取的长度


function CH341MemWriteAddr0(  // MEM方式写地址0: WR#=0, DS#/RD#=1, AS#/ADDR=0, D0-D7=output
	iIndex:cardinal;  // 指定CH341设备序号
	iBuffer:pvoid;  // 指向一个缓冲区,放置准备向地址0写出的数据
	ioLength:PULONG ):boolean;Stdcall; external 'CH341DLL.DLL' ; // 指向长度单元,输入时为准备写出的长度,返回后为实际写出的长度


Function CH341MemWriteAddr1(  // MEM方式写地址1: WR#=0, DS#/RD#=1, AS#/ADDR=1, D0-D7=output
	iIndex:cardinal;  // 指定CH341设备序号
	iBuffer:pvoid;  // 指向一个缓冲区,放置准备向地址1写出的数据
	ioLength:PULONG  ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 指向长度单元,输入时为准备写出的长度,返回后为实际写出的长度

Function CH341SetExclusive(  // 设置独占使用当前CH341设备
	iIndex:cardinal;  // 指定CH341设备序号
	iExclusive:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 为0则设备可以共享使用,非0则独占使用

Function CH341SetTimeout(  // 设置USB数据读写的超时
	iIndex:cardinal;  // 指定CH341设备序号
	iWriteTimeout:cardinal;  // 指定USB写出数据块的超时时间,以毫秒mS为单位,0xFFFFFFFF指定不超时(默认值)
	iReadTimeout:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 指定USB读取数据块的超时时间,以毫秒mS为单位,0xFFFFFFFF指定不超时(默认值)


Function CH341ReadData(  // 读取数据块
	iIndex:cardinal;  // 指定CH341设备序号
	oBuffer:PVOID;  // 指向一个足够大的缓冲区,用于保存读取的数据
	ioLength:PULONG ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 指向长度单元,输入时为准备读取的长度,返回后为实际读取的长度

Function CH341WriteData(  // 写出数据块
	iIndex:cardinal;// 指定CH341设备序号
	iBuffer:PVOID;  // 指向一个缓冲区,放置准备写出的数据
	ioLength:PULONG ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 指向长度单元,输入时为准备写出的长度,返回后为实际写出的长度

Function CH341GetDeviceName(  // 返回指向CH341设备名称的缓冲区,出错则返回NULL
	iIndex:cardinal ):PVOID;Stdcall; external 'CH341DLL.DLL' ;  // 指定CH341设备序号,0对应第一个设备

Function CH341GetVerIC(  // 获取CH341芯片的版本,返回:0=设备无效,0x10=CH341,0x20=CH341A
	iIndex:cardinal ):cardinal;Stdcall; external 'CH341DLL.DLL' ;  // 指定CH341设备序号


Function CH341FlushBuffer(  // 清空CH341的缓冲区
	iIndex:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 指定CH341设备序号

Function CH341WriteRead(  // 执行数据流命令,先输出再输入
	iIndex:cardinal;  // 指定CH341设备序号
	iWriteLength:cardinal;  // 写长度,准备写出的长度
	iWriteBuffer:PVOID;  // 指向一个缓冲区,放置准备写出的数据
	iReadStep:cardinal;  // 准备读取的单个块的长度, 准备读取的总长度为(iReadStep*iReadTimes)
	iReadTimes:cardinal;  // 准备读取的次数
	oReadLength:PULONG;  // 指向长度单元,返回后为实际读取的长度
	oReadBuffer:PVOID ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 指向一个足够大的缓冲区,用于保存读取的数据

Function CH341SetStream(  // Настройка режимов последовательного порта
	iIndex:cardinal;  // номер устройства
	iMode:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // режим
// биты 1-0: частота I2C, 00=20KHz,01=100KHz(стандартная),10=400KHz,11=750KHz
// бит 2:    настройка вводов/выводов SPI, 0=один вход/выход(D3 clk/D5 sout/D7 sin)(по умолчанию),1=два входа/выхода(D3 clk/D5 sout D4 sout/D7 sin D6 sin)
// бит 7:    передача данных по SPI, 0=Младший бит первый, 1=Старший бит первый
// Остальные биты должны быть 0

Function CH341SetDelaymS(  // 设置硬件异步延时,调用后很快返回,而在下一个流操作之前延时指定毫秒数
	iIndex:cardinal;  // 指定CH341设备序号
	iDelay:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 指定延时的毫秒数

Function CH341StreamI2C(  // обмен данными по I2C
	iIndex:cardinal;  // номер устройства
	iWriteLength:cardinal;  // Сколько байт писать
	iWriteBuffer:pvoid;  // ссылка на буфер записи(первый байт, как правило, адрес устройсва и R/W бит)
	iReadLength:cardinal;  // Сколько байт читать
	oReadBuffer:pvoid ):boolean;stdcall; external 'CH341DLL.DLL' ;  // ссылка на буфер чтения

// EEPROM型号
type
   EEPROM_TYPE =(ID_24C01,ID_24C02,ID_24C04,ID_24C08,ID_24C16,ID_24C32,ID_24C64,ID_24C128,ID_24C256,ID_24C512,ID_24C1024,ID_24C2048,ID_24C4096);

Function CH341ReadEEPROM(  // 从EEPROM中读取数据块
	iIndex:cardinal;  // 指定CH341设备序号
        iEepromID:EEPROM_TYPE;  // 指定EEPROM型号
	iAddr:cardinal;  // 指定数据单元的地址
	iLength:cardinal;  // 准备读取的数据字节数
	oBuffer:Pbytearray ):boolean;stdcall; external 'CH341DLL.DLL' ;  // 指向一个缓冲区,返回后是读入的数据


Function CH341WriteEEPROM(  // 向EEPROM中写入数据块
	iIndex:cardinal;  // 指定CH341设备序号
	iEepromID:EEPROM_TYPE;  // 指定EEPROM型号
	iAddr:cardinal;  // 指定数据单元的地址
	iLength:cardinal;  // 准备写出的数据字节数
	iBuffer:pbytearray ):boolean;stdcall; external 'CH341DLL.DLL' ;  // 指向一个缓冲区,放置准备写出的数据

Function CH341GetInput(  // 通过CH341直接输入数据和状态,效率比CH341GetStatus更高
	iIndex:cardinal;  // 指定CH341设备序号
	iStatus:PULONG ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 指向一个双字单元,用于保存状态数据,参考下面的位说明
// 位7-位0对应CH341的D7-D0引脚
// 位8对应CH341的ERR#引脚, 位9对应CH341的PEMP引脚, 位10对应CH341的INT#引脚, 位11对应CH341的SLCT引脚, 位23对应CH341的SDA引脚
// 位13对应CH341的BUSY/WAIT#引脚, 位14对应CH341的AUTOFD#/DATAS#引脚,位15对应CH341的SLCTIN#/ADDRS#引脚

Function CH341SetOutput(  // Управление портами ввода/вывода
// ***** Будте осторожны, можно коротнуть пины и все такое *****
	iIndex:cardinal;  // номер устройства
	iEnable:cardinal;  // К каким портам применять
// бит 0=1 iSetDataOut 15-8 действительны, если 0 то игнор
// бит 1=1 iSetDirOut 15-8
// бит 2=1 iSetDataOut 7-0
// бит 3=1 iSetDirOut 7-0
// бит 4=1 iSetDataOut 23-16
	iSetDirOut:cardinal;  // направление 0=вход, 1=выход. По умолчанию 0x000FC000
	iSetDataOut:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // установка состояний пинов
// биты 7-0 = D7-D0
// 8 = ERR#, 9 = PEMP, 10 = INT#, 11 = SLCT
// 13 = WAIT#, 14 = DATAS#/READ#,15 = ADDRS#/ADDR/ALE
// следующие выводы только на выход: 16 = RESET#, 17 = WRITE#, 18 = SCL, 19 = SDA

Function CH341Set_D5_D0(  // Управление портами ввода/вывода D0-D5
// ***** Будте осторожны, можно коротнуть пины, а также помешать работе SPI *****
	iIndex:cardinal;  // номер устройства
	iSetDirOut:cardinal;  // Бит 1 = выход, 0 = вход
	iSetDataOut:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // При пине настроеным на выход задается соответствующий уровень
// биты с 0-5 соответствуют портам D0-D5

Function CH341StreamSPI3(  // 处理SPI数据流,3线接口,时钟线为DCK2/SCL引脚,数据线为DIO/SDA引脚(准双向I/O),片选线为D0/D1/D2,速度约51K字节
//* SPI时序: DCK2/SCL引脚为时钟输出, 默认为低电平, DIO/SDA引脚在时钟上升沿之前输出, DIO/SDA引脚在时钟下降沿之后输入 */
	iIndex:cardinal;  // 指定CH341设备序号
	iChipSelect:cardinal;  // 片选控制, 位7为0则忽略片选控制, 位7为1则参数有效: 位1位0为00/01/10分别选择D0/D1/D2引脚作为低电平有效片选
	iLength:cardinal;  // 准备传输的数据字节数
	ioBuffer:PVOID):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 指向一个缓冲区,放置准备从DIO写出的数据,返回后是从DIO读入的数据


Function CH341StreamSPI4(  // Обмен данными с 4-х проводным SPI, CLK/D3, DOUT/D5, DIN/D7, CS D0/D1/D2, примерная скорсть 68K/s
//  Режим SPI: CLK/D3 сигнал синхронизации начинается с низкого уровня
//             DOUT/D5 по восходящему фронту
//             DIN/D7 по спадающему фронту
//  режим 0 (CPOL = 0, CPHA = 0)
	iIndex:cardinal;  // номер устройства
	iChipSelect:cardinal;  // Настройка CS, 7-ой бит 0=не дергать CS, 1=дергать соответствующий CS: биты 1-0 00/01/10 выбирают CS D0/D1/D2
	iLength:cardinal;  // Количество данных для передачи
	ioBuffer:PVOID ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // Указатель на буфер. После записи данных, сюда записываются прочтенные


Function CH341StreamSPI5(  // 处理SPI数据流,5线接口,时钟线为DCK/D3引脚,输出数据线为DOUT/D5和DOUT2/D4引脚,输入数据线为DIN/D7和DIN2/D6引脚,片选线为D0/D1/D2,速度约30K字节*2
//* SPI时序: DCK/D3引脚为时钟输出, 默认为低电平, DOUT/D5和DOUT2/D4引脚在时钟上升沿之前输出, DIN/D7和DIN2/D6引脚在时钟下降沿之后输入 */
	iIndex:cardinal;  // 指定CH341设备序号
	iChipSelect:cardinal;  // 片选控制, 位7为0则忽略片选控制, 位7为1则参数有效: 位1位0为00/01/10分别选择D0/D1/D2引脚作为低电平有效片选
	iLength:cardinal;  // 准备传输的数据字节数
	ioBuffer:PVOID;  // 指向一个缓冲区,放置准备从DOUT写出的数据,返回后是从DIN读入的数据
	ioBuffer2:PVOID ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 指向第二个缓冲区,放置准备从DOUT2写出的数据,返回后是从DIN2读入的数据

Function CH341BitStreamSPI(  // Обработка битов SPI ,4/5 проводной, DCK/D3, DOUT/DOUT2, DIN/DIN2, cs = D0/D1/D2
		iIndex:cardinal;  // номер устройства
	        iLength:cardinal;  // количество бит для передачи, максимум 896, рекомендуется 256
	        ioBuffer:PVOID ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // в буфере соответствующие биты записываются и устанавливаются после чтения
//* SPI: DCK/D3 клок, по умолчанию низкий уровень, DOUT/D5 DOUT2/D4 по восходящему фронту такта, DIN/D7 DIN2/D6 по спадающему фронту */
//* ioBuffer байт = D7-D0, 5 бит DOUT, 4 бит DOUT2, 2-0 бит D2-D0, 7 бит DIN, 6 бит DIN2, бит 3 игнорируется */
//* перед вызывом данной функции установить требуемые уровни и направление CH341Set_D5_D0 */


Function CH341SetBufUpload(  // 设定内部缓冲上传模式
	iIndex:cardinal;  // 指定CH341设备序号,0对应第一个设备
	iEnableOrClear:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 为0则禁止内部缓冲上传模式,使用直接上传,非0则启用内部缓冲上传模式并清除缓冲区中的已有数据
// 如果启用内部缓冲上传模式,那么CH341驱动程序创建线程自动接收USB上传数据到内部缓冲区,同时清除缓冲区中的已有数据,当应用程序调用CH341ReadData后将立即返回缓冲区中的已有数据


Function CH341QueryBufUpload(  // 查询内部上传缓冲区中的已有数据包个数,成功返回数据包个数,出错返回-1
	iIndex:cardinal ):integer;Stdcall; external 'CH341DLL.DLL' ;  // 指定CH341设备序号,0对应第一个设备


Function CH341SetBufDownload(  // 设定内部缓冲下传模式
	iIndex:cardinal;  // 指定CH341设备序号,0对应第一个设备
	iEnableOrClear:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 为0则禁止内部缓冲下传模式,使用直接下传,非0则启用内部缓冲下传模式并清除缓冲区中的已有数据
// 如果启用内部缓冲下传模式,那么当应用程序调用CH341WriteData后将仅仅是将USB下传数据放到内部缓冲区并立即返回,而由CH341驱动程序创建的线程自动发送直到完毕


Function CH341QueryBufDownload(  // 查询内部下传缓冲区中的剩余数据包个数(尚未发送),成功返回数据包个数,出错返回-1
	iIndex:cardinal ):integer;Stdcall; external 'CH341DLL.DLL' ;  // 指定CH341设备序号,0对应第一个设备


Function CH341ResetInter(  // 复位中断数据读操作
	iIndex:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 指定CH341设备序号


Function CH341ResetRead(  // 复位数据块读操作
	iIndex:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 指定CH341设备序号


Function 	CH341ResetWrite(  // 复位数据块写操作
	iIndex:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 指定CH341设备序号


type	 mPCH341_NOTIFY_ROUTINE =ProceDure (  // 设备事件通知回调程序
	 iEventStatus:cardinal);stdcall;  // 设备事件和当前状态(在下行定义): 0=设备拔出事件, 3=设备插入事件

const	CH341_DEVICE_ARRIVAL =		3 ;		// 设备插入事件,已经插入
	CH341_DEVICE_REMOVE_PEND =	1 ;		// 设备将要拔出
	CH341_DEVICE_REMOVE    =	0 ;		// 设备拔出事件,已经拔出


Function CH341SetDeviceNotify(  // 设定设备事件通知程序
	iIndex:cardinal;  // 指定CH341设备序号,0对应第一个设备
	iDeviceID:PCHAR;  // 可选参数,指向字符串,指定被监控的设备的ID,字符串以\0终止
	iNotifyRoutine:mPCH341_NOTIFY_ROUTINE):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 指定设备事件回调程序,为NULL则取消事件通知,否则在检测到事件时调用该程序


Function CH341SetupSerial(  // 设定CH341的串口特性,该API只能用于工作于串口方式的CH341芯片
	iIndex:cardinal;  // 指定CH341设备序号,0对应第一个设备
	iParityMode:cardinal;  // 指定CH341串口的数据校验模式: NOPARITY/ODDPARITY/EVENPARITY/MARKPARITY/SPACEPARITY
	iBaudRate:cardinal ):boolean;Stdcall; external 'CH341DLL.DLL' ;  // 指定CH341串口的通讯波特率值,可以是50至3000000之间的任意值


{ 以下API可以用于工作于串口方式的CH341芯片,除此之外的API一般只能用于并口方式的CH341芯片
	CH341OpenDevice
	CH341CloseDevice
	CH341SetupSerial
	CH341ReadData
	CH341WriteData
	CH341SetBufUpload
	CH341QueryBufUpload
	CH341SetBufDownload
	CH341QueryBufDownload
	CH341SetDeviceNotify
	CH341GetStatus
//  以上是主要API,以下是次要API
	CH341GetVersion
	CH341DriverCommand
	CH341GetDrvVersion
	CH341ResetDevice
	CH341GetDeviceDescr
	CH341GetConfigDescr
	CH341SetIntRoutine
	CH341ReadInter
	CH341AbortInter
	CH341AbortRead
	CH341AbortWrite
	CH341ReadI2C
	CH341WriteI2C
	CH341SetExclusive
	CH341SetTimeout
	CH341GetDeviceName
	CH341GetVerIC
	CH341FlushBuffer
	CH341WriteRead
	CH341ResetInter
	CH341ResetRead
	CH341ResetWrite
}
implementation


end.
