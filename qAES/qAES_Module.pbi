﻿;/ =========================
;/ =    qAES_Module.pbi    =
;/ =========================
;/
;/ [ PB V5.7x / 64Bit / All OS]
;/
;/ based on code of Werner Albus - www.nachtoptik.de
;/ 
;/ < No warranty whatsoever - Use at your own risk >
;/
;/ Module by Thorsten Hoeppner (07/2019) 
;/

; - This coder go always forward, an extra decoder isn't necessary, just use exactly the same calling convention for encrypting and decrypting!
; - This coder can handle automatic string termination for any strings - In compiler mode ASCII and UNICODE !
; - The coder works with all data lengths, also < 16 Byte

; Last Update: 06.08.2019
;
; - Changed: file format (qAES-ID added) 
; - Added:   IsCryptFile() / IsCryptPackFile()
;

;{ _____ qAES - Commands _____

; qAES::KeyStretching()             - use keystretching to make brute force attacks more difficult
; qAES::SetAttribute()              - [#EnlargeBytes/#HashLength/#ProtectedMarker/#CryptMarker]
; qAES::SetSalt()                   - define your own salt
; qAES::GetErrorMessage()           - returns error message 
; qAES::SmartCoder()                - encrypt / decrypt ascii strings, unicode strings and binary data (#Binary/#Ascii/#Unicode)
; ----- #Enable_BasicCoders -----
; qAES::EncodeFile()                - encrypt file with SmartCoder()
; qAES::DecodeFile()                - decrypt file with SmartCoder()
; qAES::String()                    - encrypt / decrypt string with SmartCoder()
; qAES::String2File()               - create an encryoted string file
; qAES::File2String()               - read an encrypted string file
; qAES::IsCryptFile()               - checks if the file is encrypted.
; ----- #Enable_LoadSaveCrypt -----
; qAES::LoadCryptImage()            - similar to LoadImage()
; qAES::SaveCryptImage()            - similar to SaveImage()
; qAES::LoadCryptJSON()             - similar to LoadJSON()
; qAES::SaveCryptJSON()             - similar to SaveJSON()
; qAES::LoadCryptXML()              - similar to LoadXML()
; qAES::SaveCryptXML()              - similar to SaveXML()
; ----- #Enable_CryptPacker -----
; qAES::AddCryptPackFile()          - similar to AddPackFile()
; qAES::UncompressCryptPackFile()   - similar to UncompressPackFile()
; qAES::AddCryptPackMemory()        - similar to AddPackMemory()
; qAES::UncompressCryptPackMemory() - similar to UncompressPackMemory()
; qAES::AddCryptPackXML()           - similar to SaveXML(), but for packer
; qAES::UncompressCryptPackXML()    - similar to LoadXML(), but for packer
; qAES::AddCryptPackJSON()          - similar to SaveJSON(), but for packer
; qAES::UncompressCryptPackJSON()   - similar to LoadJSON(), but for packer
; qAES::AddCryptPackImage()         - similar to SaveImage(), but for packer
; qAES::UncompressCryptPackImage()  - similar to LoadImage(), but for packer
; qAES::IsCryptPackFile()           - checks if the packed file is encrypted
; ----- #Enable_SmartFileCoder -----
; qAES::SmartFileCoder()            - encrypting or decrypting file (high security)
; qAES::CheckIntegrity()            - checks the integrity of a encrypted file      [SmartFileCoder]
; qAES::IsEncrypted()               - checks if a file is already encrypted         [SmartFileCoder]
; qAES::IsProtected()               - checks if a file is already protected         [SmartFileCoder]

;}


DeclareModule qAES
  
  #Enable_BasicCoders    = #True
  #Enable_SmartFileCoder = #True
  #Enable_LoadSaveCrypt  = #True
  #Enable_CryptPacker    = #True
  
	;- ===========================================================================
	;-   DeclareModule - Constants
	;- ===========================================================================

  Enumeration
    #Binary          ; Mode BINARY, you can encrypt binary data, don't use this for on demand string encryption, it break the string termination!
    #Ascii           ; Mode ASCII, you can encrypt mixed data, string and binary - This ignore the encryption of zero bytes, recommended for mixed datea with ASCII strings.
    #Unicode         ; Mode UNICODE, you can encrypt mixed data, ascii strings, unicode strings and binary - This ignore the encryption of zero bytes.
  EndEnumeration
  
  Enumeration 1
    #CryptMarker     ; preset crypt marker
    #EnlargeBytes    ; enlarge file length bytes
    #HashLength      ; (224, 256, 384, 512)
    #ProtectedMarker ; preset protected marker
  EndEnumeration
  
  Enumeration 1
    #ERROR_CAN_NOT_CREATE_COUNTER
    #ERROR_FINGERPRINT_FAILS
    #ERROR_FILE_NOT_EXIST
    #ERROR_CAN_NOT_OPEN_FILE
    #ERROR_ENCODING_FAILS
    #ERROR_NOT_QAES_ENCRYPTED
  EndEnumeration
  
	;- ===========================================================================
	;-   DeclareModule
  ;- ===========================================================================
  
  CompilerIf #Enable_BasicCoders
    Declare.i DecodeFile(File.s, Key.s, outFile.s="", KeyStretching.i=#False) 
    Declare.i EncodeFile(File.s, Key.s, outFile.s="", KeyStretching.i=#False) 
    Declare.s File2String(File.s, Key.s, KeyStretching.i=#False)
    Declare.s String(String.s, Key.s, KeyStretching.i=#False) 
    Declare.i String2File(String.s, File.s, Key.s, KeyStretching.i=#False)
    Declare.i IsCryptFile(File.s)
  CompilerEndIf
  
  CompilerIf #Enable_SmartFileCoder
    Declare.i CheckIntegrity(File.s, Key.s, CryptExtension.s="", ProtectionMode.i=#False)
    Declare.i SmartFileCoder(File.s, Key.s, CryptExtension.s="", ProtectionMode.i=#False)
    Declare.i IsEncrypted(File.s, Key.s, CryptExtension.s="", ProtectionMode.i=#False)
    Declare.i IsProtected(File.s, Key.s, CryptExtension.s="", ProtectionMode.i=#False)
  CompilerEndIf
  
  CompilerIf #Enable_LoadSaveCrypt
    Declare.i LoadCryptImage(Image.i, File.s, Key.s, KeyStretching.i=#False)
    Declare.i LoadCryptJSON(JSON.i, File.s, Key.s, KeyStretching.i=#False)
    Declare.i LoadCryptXML(XML.i, File.s, Key.s, KeyStretching.i=#False)
    Declare.i SaveCryptImage(Image.i, File.s, Key.s, KeyStretching.i=#False)
    Declare.i SaveCryptJSON(JSON.i, File.s, Key.s, KeyStretching.i=#False)
    Declare.i SaveCryptXML(XML.i, File.s, Key.s, KeyStretching.i=#False)
  CompilerEndIf
  
  CompilerIf #Enable_CryptPacker
    
    Declare.i AddCryptPackFile(Pack.i, File.s, Key.s, KeyStretching.i=#False)
    Declare.i UncompressCryptPackFile(Pack.i, File.s, Key.s, PackedFileName.s="", KeyStretching.i=#False)
    
    Declare.i AddCryptPackMemory(Pack.i, *Buffer, Size.i, Key.s, PackedFileName.s, KeyStretching.i=#False)
    Declare.i UncompressCryptPackMemory(Pack.i, *Buffer, Size.i, Key.s, PackedFileName.s="", KeyStretching.i=#False)
    
    Declare.i AddCryptPackXML(Pack.i, XML.i, Key.s, PackedFileName.s, KeyStretching.i=#False)
    Declare.i UncompressCryptPackXML(Pack.i, XML.i, Key.s, PackedFileName.s="", KeyStretching.i=#False)
    
    Declare.i AddCryptPackJSON(Pack.i, JSON.i, Key.s, PackedFileName.s, KeyStretching.i=#False)
    Declare.i UncompressCryptPackJSON(Pack.i, JSON.i, Key.s, PackedFileName.s="", KeyStretching.i=#False)
    
    Declare.i AddCryptPackImage(Pack.i, Image.i, Key.s, PackedFileName.s, KeyStretching.i=#False)
    Declare.i UncompressCryptPackImage(Pack.i, Image.i, Key.s, PackedFileName.s="", KeyStretching.i=#False)
    
    Declare.i IsCryptPackFile(Pack.i, PackedFileName.s)
    
  CompilerEndIf
  
  Declare.i SmartCoder(Mode.i, *Input.word, *Output.word, Size.q, Key.s, CounterKey.q=0, CounterAES.q=0)
  Declare.s KeyStretching(Key.s, Loops.i, ProgressBarID.i=#PB_Default, WindowID.i=#PB_Default)
  Declare   SetAttribute(Attribute.i, Value.i)
  Declare   SetSalt(String.s)
  Declare.s GetErrorMessage(Error.i)
  
EndDeclareModule

Module qAES

	EnableExplicit
	
	UseSHA3Fingerprint()
	
	;- ============================================================================
	;-   Module - Constants
	;- ============================================================================
	
	#Hints$ = "QUICK-AES-256 (QAES) AES256 KFB crypter" + #LF$ + "No warranty whatsever - Use at your own risk" + #LF$ + #LF$
  #Salt$  = "t8690352cj2p1ch7fgw34u&=)?=)/%&§/&)=?(otmq09745$%()=)&%"
  
	;- ============================================================================
  ;-   Module - Structure
	;- ============================================================================
	
	Structure AES_Structure ;{ qAES\...
	  CryptExtLength.i
	  EnlargeBytes.i
	  HashLength.i
	  ProtectedMarker.q
	  CryptMarker.q
	  Salt.s
	  Error.i
	EndStructure ;}
	Global qAES.AES_Structure

	;- ==========================================================================
	;-   Module - Declared Procedures
	;- ==========================================================================
  
  ;- _____ Tools _____
  
  Procedure.s KeyStretching(Key.s, Loops.i, ProgressBarID.i=#PB_Default, WindowID.i=#PB_Default)
    Define.i i, Time.q, Progress
    
    If ProgressBarID <> #PB_Default And WindowID <> #PB_Default
      Progress = #True
      Time = ElapsedMilliseconds()
    EndIf 
    
    For i=1 To Loops ; Iterations
      
      Key = Fingerprint(@Key, StringByteLength(Key), #PB_Cipher_SHA3, 512)
      Key = ReverseString(qAES\Salt) + Key + qAES\Salt + ReverseString(Key)
      
      If Progress 
        If ElapsedMilliseconds() > Time + 100
          If IsGadget(ProgressBarID) : SetGadgetState(ProgressBarID, 100 * i / Loops) : EndIf
          Time = ElapsedMilliseconds()  
        EndIf
      EndIf
      
    Next
    
    Key = Fingerprint(@Key, StringByteLength(Key), #PB_Cipher_SHA3, 512) ; Finalize
    
    If Progress
      If IsGadget(ProgressBarID) : SetGadgetState(ProgressBarID, 100) : EndIf
      Delay(100)
    EndIf
    
    ProcedureReturn Key
  EndProcedure
  
  Procedure.s GetErrorMessage(Error.i)
    
    Select Error
      Case #ERROR_CAN_NOT_CREATE_COUNTER
        ProcedureReturn "Error: Can't create counter."
      Case #ERROR_FINGERPRINT_FAILS
        ProcedureReturn "Error: Fingerprint not valid."
      Case #ERROR_FILE_NOT_EXIST
        ProcedureReturn "Error: File not found."
      Case #ERROR_CAN_NOT_OPEN_FILE
        ProcedureReturn "Error: Can't open file."
      Case #ERROR_ENCODING_FAILS
        ProcedureReturn "No error found."
      Case #ERROR_NOT_QAES_ENCRYPTED
        ProcedureReturn "Not qAES encrypted."
    EndSelect
    
    ProcedureReturn "No error found."
  EndProcedure
  
  ;- _____ Settings _____
  
  Procedure   SetAttribute(Attribute.i, Value.i)
    
    Select Attribute
      Case #EnlargeBytes
        qAES\EnlargeBytes = Value
      Case #HashLength
        qAES\HashLength = Value
      Case #ProtectedMarker
        qAES\ProtectedMarker = Value
      Case #CryptMarker
        qAES\CryptMarker = Value
    EndSelect
    
  EndProcedure

  Procedure   SetSalt(String.s)
	  qAES\Salt = String
	EndProcedure
	
	;- _____ SmartCoder _____
	
	Procedure.i SmartCoder(Mode.i, *Input.word, *Output.word, Size.q, Key.s, CounterKey.q=0, CounterAES.q=0)
	  ; Author: Werner Albus - www.nachtoptik.de (No warranty whatsoever - Use at your own risk)
    ; CounterKey: If you cipher a file blockwise, always set the current block number with this counter (consecutive numbering).
    ; CounterAES: This counter will be automatically used by the coder, but you can change the startpoint.
	  Define.i i, ii, iii, cStep
	  Define.q Rounds, Remaining
	  Define.s Hash$
	  Define   *aRegister.ascii, *wRegister.word, *aBufferIn.ascii, *aBufferOut.ascii, *qBufferIn.quad, *qBufferOut.quad
	  Static   FixedKey${64}
	  Static   Dim Register.q(3)
	  
	  If qAES\Salt = "" : qAES\Salt = #Salt$ : EndIf
	  
	  Hash$     = qAES\Salt + Key + Str(CounterKey) + ReverseString(qAES\Salt)
	  FixedKey$ = Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, 256)	  
	  
	  cStep     = SizeOf(character) << 1
	  Rounds    = Size >> 4
	  Remaining = Size % 16
	  
	  For ii = 0 To 31
	    PokeA(@Register(0) + ii, Val("$" + PeekS(@FixedKey$ + iii, 2)))
	    iii + cStep
	  Next
	  
	  Register(1) + CounterAES

	  Select Mode
	    Case #Binary  ;{ Binary content
	      
	      *qBufferIn  = *Input
	      *qBufferOut = *Output
	      
	      If Size < 16 ;{ Size < 16
	        
	        *aBufferOut = *qBufferOut
	        *aBufferIn  = *qBufferIn
	        *aRegister  = @register(0)
	        
	        If Not AESEncoder(@Register(0), @Register(0), 32, @Register(0), 256, 0, #PB_Cipher_ECB)
	          qAES\Error = #ERROR_ENCODING_FAILS
	          ProcedureReturn #False
	        EndIf
	        
          For ii=0 To Size - 1
            *aBufferOut\a = *aBufferIn\a ! *aRegister\a
            *aBufferIn  + 1
            *aBufferOut + 1
            *aRegister  + 1
          Next
          
          ProcedureReturn #True
          ;}
        EndIf
        
        While i < Rounds ;{ >= 16 Byte
          
          If Not AESEncoder(@register(0), @register(0), 32, @register(0), 256, 0, #PB_Cipher_ECB)
            qAES\Error = #ERROR_ENCODING_FAILS
            ProcedureReturn #False
          EndIf
          
          *qBufferOut\q=*qBufferIn\q ! register(0)
          *qBufferIn  + 8
          *qBufferOut + 8
          *qBufferOut\q = *qBufferIn\q ! register(1)
          *qBufferIn  + 8
          *qBufferOut + 8
          
          i + 1
        Wend ;}
        
        If Remaining
          
          *aBufferOut = *qBufferOut
          *aBufferIn  = *qBufferIn
          *aRegister  = @Register(0)
          
          If Not AESEncoder(@register(0), @register(0), 32, @register(0), 256, 0, #PB_Cipher_ECB)
            qAES\Error = #ERROR_ENCODING_FAILS
            ProcedureReturn #False
          EndIf
          
          For ii=0 To Remaining - 1
            *aBufferOut\a = *aBufferIn\a ! *aRegister\a
            *aBufferIn  + 1
            *aBufferOut + 1
            *aRegister  + 1
          Next
          
        EndIf
	      ;}
	    Case #Ascii   ;{ Ascii content
	      
	      *aBufferIn  = *Input
	      *aBufferOut = *Output
	      
	      Repeat
	        
	        If Not AESEncoder(@register(0), @register(0), 32, @register(0), 256, 0, #PB_Cipher_ECB)
	          qAES\Error = #ERROR_ENCODING_FAILS
	          ProcedureReturn #False
	        EndIf
	        
	        *aRegister = @Register(0)
	        
	        For ii=0 To 15
	          
            If *aBufferIn\a And *aBufferIn\a ! *aRegister\a
              *aBufferOut\a = *aBufferIn\a ! *aRegister\a
            Else
              *aBufferOut\a = *aBufferIn\a
            EndIf
            
            If i > Size - 2 : Break 2 : EndIf
            
            *aBufferIn  + 1
            *aBufferOut + 1
            *aRegister  + 1
            
            i + 1
          Next ii
          
        ForEver
  	    ;}
	    Case #Unicode ;{ Unicode content
	      
	      Repeat
	        
	        If Not AESEncoder(@Register(0), @Register(0), 32, @Register(0), 256, 0, #PB_Cipher_ECB)
	          qAES\Error = #ERROR_ENCODING_FAILS
	          ProcedureReturn #False
	        EndIf
	        
	        *wRegister = @Register(0)
          
	        For ii=0 To 15 Step 2
	          
            If *Input\w And *Input\w ! *wRegister\w
              *Output\w = *Input\w ! *wRegister\w
            Else
              *Output\w = *Input\w
            EndIf
            
            If i > Size - 3 : Break 2 : EndIf
            
            *Input + 2
            *Output + 2
            *wRegister + 2
            
            i + 2
          Next ii
          
        ForEver
	      
	      ;}
	  EndSelect
	  
	  ProcedureReturn #True
	EndProcedure
	
	CompilerIf #Enable_SmartFileCoder
	
  	Procedure.i SmartFileCoder(File.s, Key.s, CryptExtension.s="", ProtectionMode.i=#False)
  	  ; Set ProtectionMode <> 0 activates the file protection mode (against changes)
  	  ; Set on this variable to define the CounterAES from the universal crypter
      ; This protect a file, but dont encrypt the file. Mostly files you can normaly use protected
  	  Define.i i, CryptRandom, EncryptedFileFound, HashBytes
  	  Define.i FileID, BlockSize, Blocks, BlockCounter, Remaining
  	  Define.q Counter, cCounter, spCounter, Magic
  	  Define.q FileSize, fCounter, ReadBytes, WritenBytes, fMagic ; File data
  	  Define.s Key$, Hash$, cHash$
  	  Define   *Buffer
  	  
  	  If CryptExtension
  	    If FileSize(GetFilePart(File, #PB_FileSystem_NoExtension) + CryptExtension + "." + GetExtensionPart(File)) > 0
  	      File = GetFilePart(File, #PB_FileSystem_NoExtension) + CryptExtension + "." + GetExtensionPart(File)
  	    EndIf
  	  EndIf
  	  
  	  If FileSize(File) <= 0
  	    qAES\Error = #ERROR_FILE_NOT_EXIST
  	    ProcedureReturn #False
  	  EndIf
  	  
  	  If qAES\CryptMarker     = 0 : qAES\CryptMarker     = 415628580943792148170 : EndIf
  	  If qAES\EnlargeBytes    = 0 : qAES\EnlargeBytes    = 128    : EndIf
  	  If qAES\HashLength      = 0 : qAES\HashLength      = 256    : EndIf
  	  If qAES\ProtectedMarker = 0 : qAES\ProtectedMarker = 275390641757985374251 : EndIf
  	  If qAES\Salt = ""           : qAES\Salt            = #Salt$ : EndIf
  	  
  	  qAES\CryptExtLength = 8 + 8 + qAES\HashLength >> 3
  	  Dim Hash.q(qAES\HashLength >> 3 - 1)
  	  
  	  If ProtectionMode ;{ Counter / Magic
  	    
        Counter = ProtectionMode
        Magic   = qAES\ProtectedMarker
        
      Else
        
        If OpenCryptRandom()
          CryptRandom = #True
          CryptRandomData(@Counter, 8)
        Else
          CryptRandom = #False
          RandomData(@Counter, 8)
        EndIf
        
        Magic = qAES\CryptMarker
        
        If Not Counter 
          qAES\Error = #ERROR_CAN_NOT_CREATE_COUNTER
          ProcedureReturn #False
        EndIf
        ;}
      EndIf
      
      If Len(Fingerprint(@Magic, 8, #PB_Cipher_SHA3, qAES\HashLength)) <> qAES\HashLength >> 2 ; Check Fingerprint
        qAES\Error = #ERROR_FINGERPRINT_FAILS
        ProcedureReturn #False
      EndIf
      
      Key$  = ReverseString(qAES\Salt) + Key + qAES\Salt + ReverseString(Key)
      Key$  = Fingerprint(@Key$, StringByteLength(Key$), #PB_Cipher_SHA3, 512)
      
      SmartCoder(#Binary, @Magic, @Magic, 8, qAES\Salt + ReverseString(Key$) + Str(Magic) + Key$)
  
      FileID = OpenFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        BlockSize = 4096 << 2
        FileBuffersSize(FileID, BlockSize)
        
        *Buffer = AllocateMemory(BlockSize)
        If *Buffer
          
          FileSeek(FileID, FileSize - qAES\CryptExtLength)
          
          ;{ Read file header
          ReadData(FileID, @fCounter, 8)
          ReadData(FileID, @fMagic, 8)
          ReadData(FileID, @Hash(0), qAES\HashLength >> 3)
          FileSeek(FileID, 0)
          ;}
          
          ;{ Decrypt file header
          SmartCoder(#Binary, @fCounter, @fCounter, 8, ReverseString(Key$) + Key$ + qAES\Salt)
          SmartCoder(#Binary, @fMagic, @fMagic, 8, ReverseString(Key$) + Key$, fCounter)
          SmartCoder(#Binary, @Hash(0), @Hash(0), qAES\HashLength >> 3, Key$ + ReverseString(Key$), fCounter)
          ;}
          
          If fMagic = Magic ;{ File encrypted?
          
            cCounter = fCounter
            EncryptedFileFound = #True
            
          Else
    
            SmartCoder(#Binary, @Magic, @Magic, 8, ReverseString(Key$) + Key$, Counter) ; Encrypt magic
            cCounter = Counter
            ;}
          EndIf
          
          Blocks    = (FileSize - qAES\CryptExtLength) / BlockSize
          Remaining = FileSize - (BlockSize * Blocks)
          
          If EncryptedFileFound : Remaining - qAES\CryptExtLength : EndIf
          
          Repeat 
            
            ReadBytes = ReadData(FileID, *Buffer, BlockSize)
        
            If EncryptedFileFound ;{ File encrypted
            
              HashBytes = ReadBytes - qAES\CryptExtLength
          
              If ReadBytes = BlockSize : HashBytes = ReadBytes : EndIf
  
              If HashBytes > 0
                
                BlockCounter + 1
                
                If Remaining 
                  If BlockCounter > Remaining : HashBytes = Remaining : EndIf
                Else
                  HashBytes = FileSize - qAES\CryptExtLength
                EndIf
                
                Hash$  = Fingerprint(*buffer, HashBytes, #PB_Cipher_SHA3, qAES\HashLength)
                Hash$ + Key$ + cHash$ + Str(cCounter)
                Hash$  = Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, qAES\HashLength)
                cHash$ = Hash$
                
              EndIf
  
              If Not ProtectionMode
                SmartCoder(#Binary, *Buffer, *Buffer, BlockSize, Key$, cCounter, spCounter) ; QAES crypter
              EndIf
              ;}
            Else                  ;{ File not encrypted
              
              If Not ProtectionMode
                SmartCoder(#Binary, *Buffer, *Buffer, BlockSize, Key$, cCounter, spCounter) ; QAES crypter
              EndIf
              
              If ReadBytes > 0
                Hash$  = Fingerprint(*Buffer, ReadBytes, #PB_Cipher_SHA3, qAES\HashLength)
                Hash$ + Key$ + cHash$ + Str(cCounter)
                Hash$  = Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, qAES\HashLength)
                cHash$ = Hash$ 
              EndIf
              ;}
            EndIf
            
            FileSeek(FileID, -ReadBytes, #PB_Relative)
            WritenBytes + WriteData(FileID, *Buffer, ReadBytes)
            
            cCounter  + 1
            spCounter + 1
            
          Until ReadBytes = 0
          
          Hash$ + Key$ + qAES\Salt ; Finishing fingerprint
          Hash$ = LCase(Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, qAES\HashLength))
          
          If EncryptedFileFound ;{ File encrypted
            
            FileSeek(FileID, -qAES\CryptExtLength, #PB_Relative)
            TruncateFile(FileID)
            
            ;}
          Else                  ;{ File not encrypted
            
            For i=0 To qAES\HashLength >> 3 - 1
              PokeA(@Hash(0) + i, Val("$" + PeekS(@Hash$ + i *SizeOf(character) << 1, 2)))
            Next
            
            ;{ Crypt file header
            SmartCoder(#Binary, @Hash(0), @Hash(0), qAES\HashLength >> 3, Key$ + ReverseString(Key$), Counter)
            SmartCoder(#Binary, @Counter, @Counter, 8, ReverseString(Key$) + Key$ + qAES\Salt)
            ;}
            
            WritenBytes + WriteData(FileID, @Counter, 8)
            WritenBytes + WriteData(FileID, @Magic, 8)
            WritenBytes + WriteData(FileID, @Hash(0), qAES\HashLength >> 3)
            
            ;}
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
        CloseFile(FileID)
        
        If CryptExtension
          
          If EncryptedFileFound
            RenameFile(File, RemoveString(File, CryptExtension))
          Else
            RenameFile(File, GetFilePart(File, #PB_FileSystem_NoExtension) + CryptExtension + "." + GetExtensionPart(File))
          EndIf
          
        Else
          
          If EncryptedFileFound
            RenameFile(File, RemoveString(File, ".aes", #PB_String_NoCase, Len(File) - 4))
          Else
            RenameFile(File, File + ".aes")
          EndIf
          
        EndIf
        
      Else 
        qAES\Error = #ERROR_CAN_NOT_OPEN_FILE
        ProcedureReturn #False
      EndIf
      
  	EndProcedure
  	
    Procedure.i CheckIntegrity(File.s, Key.s, CryptExtension.s="", ProtectionMode.i=#False)
  	  Define.q FileSize, Counter, fCounter, cCounter, spCounter, ReadBytes, WritenBytes, Magic, fMagic
  	  Define.i FileID, CryptRandom, EncryptedFileFound, CheckIntegrity, FileBroken
  	  Define.i i, Blocks, BlockSize, Remaining, HashBytes, BlockCounter
  	  Define.s Key$, Hash$, fHash$, cHash$
  	  Define   *Buffer
  	  
  	  If CryptExtension ;{
  	    If FileSize(GetFilePart(File, #PB_FileSystem_NoExtension) + CryptExtension + "." + GetExtensionPart(File)) > 0
  	      File = GetFilePart(File, #PB_FileSystem_NoExtension) + CryptExtension + "." + GetExtensionPart(File)
  	    EndIf ;}
  	  EndIf
  	  
  	  If FileSize(File) <= 0
  	    qAES\Error = #ERROR_FILE_NOT_EXIST
  	    ProcedureReturn #False
  	  EndIf
  	  
  	  If qAES\CryptMarker     = 0 : qAES\CryptMarker     = 415628580943792148170 : EndIf
  	  If qAES\ProtectedMarker = 0 : qAES\ProtectedMarker = 275390641757985374251 : EndIf
  	  If qAES\HashLength      = 0 : qAES\HashLength      = 256    : EndIf
  	  If qAES\Salt = "" : qAES\Salt = #Salt$ : EndIf
  	  
  	  qAES\CryptExtLength = 8 + 8 + qAES\HashLength >> 3
  	  Dim Hash.q(qAES\HashLength >> 3 - 1)
  	  
  	  If ProtectionMode ;{ Counter / Magic
  	    
        Counter = ProtectionMode
        Magic   = qAES\ProtectedMarker
        
      Else
        
        If OpenCryptRandom()
          CryptRandom = #True
          CryptRandomData(@Counter, 8)
        Else
          CryptRandom = #False
          RandomData(@Counter, 8)
        EndIf
        
        Magic = qAES\CryptMarker
        
        If Not Counter 
          qAES\Error = #ERROR_CAN_NOT_CREATE_COUNTER
          ProcedureReturn #False
        EndIf
        ;}
      EndIf
      
      If Len(Fingerprint(@Magic, 8, #PB_Cipher_SHA3, qAES\HashLength)) <> qAES\HashLength >> 2
        qAES\Error = #ERROR_FINGERPRINT_FAILS
        ProcedureReturn #False
      EndIf
      
      Key$  = ReverseString(qAES\Salt) + Key + qAES\Salt + ReverseString(Key)
      Key$  = Fingerprint(@Key$, StringByteLength(Key$), #PB_Cipher_SHA3, 512)
      
      SmartCoder(#Binary, @Magic, @Magic, 8, qAES\Salt + ReverseString(Key$) + Str(Magic) + Key$)
      
  	  FileID = ReadFile(#PB_Any, File)
  	  If FileID
  	    
  	    FileSize = Lof(FileID)
  	    
  	    BlockSize = 4096 << 2
        FileBuffersSize(FileID, BlockSize)
        
        *Buffer = AllocateMemory(BlockSize)
        If *Buffer
  	    
    	    FileSeek(FileID, FileSize - qAES\CryptExtLength)
    	    
    	    ;{ Read file header
    	    ReadData(FileID, @fCounter, 8)
    	    ReadData(FileID, @fMagic, 8)
    	    ReadData(FileID, @Hash(0), qAES\HashLength >> 3)
          FileSeek(FileID, 0)
          ;}
  
          ;{ Decrypt file header
    	    SmartCoder(#Binary, @fCounter, @fCounter, 8, ReverseString(Key$) + Key$ + qAES\Salt)
          SmartCoder(#Binary, @fMagic,   @fMagic,   8, ReverseString(Key$) + Key$, fCounter)
          SmartCoder(#Binary, @Hash(0),  @Hash(0), qAES\HashLength >> 3, Key$ + ReverseString(Key$), fCounter)
          ;}
          
          If fMagic = Magic ;{ File encrypted
            
            EncryptedFileFound = #True
            cCounter = fCounter
            
            For i = 0 To qAES\HashLength >> 3 - 1
              fHash$ + RSet(Hex(PeekA(@Hash(0) + i)), 2, "0")
            Next i
            fHash$ = LCase(fHash$)
            ;}
          Else              ;{ File not encrypted
            
            SmartCoder(#Binary, @Magic, @Magic, 8, ReverseString(Key$) + Key$, Counter)
            cCounter = Counter
           
            ;}
          EndIf    
          
          Blocks    = (FileSize - qAES\CryptExtLength) / BlockSize
          Remaining = FileSize - (BlockSize * Blocks)
         
          If EncryptedFileFound : Remaining - qAES\CryptExtLength : EndIf
          
          Repeat 
            
            ReadBytes = ReadData(FileID, *Buffer, BlockSize)
            
            If EncryptedFileFound ;{ File encrypted
              
              HashBytes = ReadBytes - qAES\CryptExtLength
          
              If ReadBytes = BlockSize : HashBytes = ReadBytes : EndIf
              
              If HashBytes > 0
                
                BlockCounter + 1
                
                If Remaining 
                  If BlockCounter > Remaining : HashBytes = Remaining : EndIf
                Else
                  HashBytes = FileSize - qAES\CryptExtLength
                EndIf
                
                Hash$  = Fingerprint(*Buffer, HashBytes, #PB_Cipher_SHA3, qAES\HashLength)
                Hash$ + Key$ + cHash$ + Str(cCounter)
                Hash$  = Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, qAES\HashLength)
                cHash$ = Hash$
  
              EndIf
              
              If Not ProtectionMode
                SmartCoder(#Binary, *Buffer, *Buffer, BlockSize, Key$, cCounter, spCounter) ; QAES crypter
              EndIf
              ;}
            Else                  ;{ File not encrypted  
              
              If Not ProtectionMode
                SmartCoder(#Binary, *Buffer, *Buffer, BlockSize, Key$, cCounter, spCounter) ; QAES crypter
              EndIf
              
              If ReadBytes > 0
                Hash$  = Fingerprint(*Buffer, ReadBytes, #PB_Cipher_SHA3, qAES\HashLength)
                Hash$ + Key$ + cHash$ + Str(cCounter)
                Hash$  = Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, qAES\HashLength)
                cHash$ = Hash$ 
              EndIf
              ;}
            EndIf
            
            WritenBytes + ReadBytes
            
            cCounter  + 1
            spCounter + 1
            
          Until ReadBytes = 0
          
          Hash$ + Key$ + qAES\Salt ; Finishing fingerprint
          Hash$ = LCase(Fingerprint(@Hash$, StringByteLength(Hash$), #PB_Cipher_SHA3, qAES\HashLength))
          
          If EncryptedFileFound
            If Hash$ <> fHash$ : FileBroken = #True : EndIf
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
        CloseFile(FileID)
      Else 
        qAES\Error = #ERROR_CAN_NOT_OPEN_FILE
        ProcedureReturn #False  
  	  EndIf
  	  
  	  If FileBroken
  	    ProcedureReturn #False
  	  Else
  	    ProcedureReturn #True
  	  EndIf
  	  
  	EndProcedure
  	
  	Procedure.i IsEncrypted(File.s, Key.s, CryptExtension.s="", ProtectionMode.i=#False)
  	  Define.q FileSize, Counter, fCounter, Magic, fMagic
  	  Define.i FileID, CryptRandom, EncryptedFileFound
  	  Define.s Key$
  	  
  	  If CryptExtension
  	    If FileSize(GetFilePart(File, #PB_FileSystem_NoExtension) + CryptExtension + "." + GetExtensionPart(File)) > 0
  	      File = GetFilePart(File, #PB_FileSystem_NoExtension) + CryptExtension + "." + GetExtensionPart(File)
  	    EndIf
  	  EndIf
  	  
  	  If FileSize(File) <= 0
  	    qAES\Error = #ERROR_FILE_NOT_EXIST
  	    ProcedureReturn #False
  	  EndIf
  	  
  	  If qAES\CryptMarker     = 0 : qAES\CryptMarker     = 415628580943792148170 : EndIf
  	  If qAES\ProtectedMarker = 0 : qAES\ProtectedMarker = 275390641757985374251 : EndIf
  	  If qAES\HashLength      = 0 : qAES\HashLength      = 256    : EndIf
  	  If qAES\Salt = "" : qAES\Salt = #Salt$ : EndIf
  	  
  	  qAES\CryptExtLength = 8 + 8 + qAES\HashLength >> 3
  	  
  	  If ProtectionMode ;{ Counter / Magic
  	    
        Counter = ProtectionMode
        Magic   = qAES\ProtectedMarker
        
      Else
        
        If OpenCryptRandom()
          CryptRandom = #True
          CryptRandomData(@Counter, 8)
        Else
          CryptRandom = #False
          RandomData(@Counter, 8)
        EndIf
        
        Magic = qAES\CryptMarker
        
        If Not Counter 
          qAES\Error = #ERROR_CAN_NOT_CREATE_COUNTER
          ProcedureReturn #False
        EndIf
        ;}
      EndIf
      
      If Len(Fingerprint(@Magic, 8, #PB_Cipher_SHA3, qAES\HashLength)) <> qAES\HashLength >> 2
        qAES\Error = #ERROR_FINGERPRINT_FAILS
        ProcedureReturn #False
      EndIf
      
      Key$  = ReverseString(qAES\Salt) + Key + qAES\Salt + ReverseString(Key)
      Key$  = Fingerprint(@Key$, StringByteLength(Key$), #PB_Cipher_SHA3, 512)
      
      SmartCoder(#Binary, @Magic, @Magic, 8, qAES\Salt + ReverseString(Key$) + Str(Magic) + Key$)
      
  	  FileID = ReadFile(#PB_Any, File)
  	  If FileID
  	    
  	    FileSize = Lof(FileID)
  	    
  	    FileSeek(FileID, FileSize - qAES\CryptExtLength)
  	    
  	    ReadData(FileID, @fCounter, 8)
  	    ReadData(FileID, @fMagic, 8)
  	    
  	    SmartCoder(#Binary, @fCounter, @fCounter, 8, ReverseString(Key$) + Key$ + qAES\Salt)
        SmartCoder(#Binary, @fMagic,   @fMagic,   8, ReverseString(Key$) + Key$, fCounter)
        
        If fMagic = Magic 
          EncryptedFileFound = #True
        EndIf    
     
        CloseFile(FileID)
      Else 
        qAES\Error = #ERROR_CAN_NOT_OPEN_FILE
        ProcedureReturn #False  
  	  EndIf
  	  
  	  ProcedureReturn EncryptedFileFound
  	EndProcedure
  	
  	Procedure.i IsProtected(File.s, Key.s, CryptExtension.s="", ProtectionMode.i=#False)
  	  
  	  ProcedureReturn IsEncrypted(File, Key, CryptExtension, ProtectionMode)
  	  
  	EndProcedure
  	
	CompilerEndIf
	
	;- _____ Encode / Decode only _____
	
	CompilerIf #Enable_BasicCoders
	  
    Procedure.s String(String.s, Key.s, KeyStretching.i=#False) 
      ; KeyStretching: number of loops for KeyStretching()
      Define   *Input, *Output
      Define.i StrgSize
      Define.s Output$
      
      If KeyStretching
        Key = KeyStretching(Key, KeyStretching)
      EndIf     
  
      *Input = @String
      If *Input
        CompilerIf #PB_Compiler_Unicode
    
          StrgSize = StringByteLength(String, #PB_Unicode) + 2
          If StrgSize
            *Output = AllocateMemory(StrgSize)
            If *Output
              SmartCoder(#Unicode, *Input, *Output, StrgSize, Key)
              Output$ = PeekS(*Output, StrgSize, #PB_Unicode)
              FreeMemory(*Output)
            EndIf
          EndIf
          
        CompilerElse
          
          StrgSize = StringByteLength(String, #PB_Ascii) + 1
          If StrgSize
            *Output = AllocateMemory(StrgSize)
            If *Output
              SmartCoder(#Ascii, *Input, *Output, StrgSize, Key)
              Output$ = PeekS(*Output, StrgSize, #PB_Ascii)
              FreeMemory(*Output)
            EndIf
          EndIf
          
        CompilerEndIf
      EndIf
      
      ProcedureReturn Output$
    EndProcedure
    
    Procedure.i String2File(String.s, File.s, Key.s, KeyStretching.i=#False) 
      Define   *Output
      Define.q Counter
      Define.i FileID, StrgSize, Result
      Define.s ID$
      
      If KeyStretching
        Key = KeyStretching(Key, KeyStretching)
      EndIf
      
      If OpenCryptRandom()
        CryptRandomData(@Counter, 8)
      Else
        RandomData(@Counter, 8)
      EndIf
      
      ID$ = DESFingerprint("qAES", Str(Counter))
      
      CompilerIf #PB_Compiler_Unicode

        StrgSize = StringByteLength(String, #PB_Unicode) + 2
        If StrgSize
  
          *Output = AllocateMemory(StrgSize + 8)
          If *Output
            
            SmartCoder(#Binary, @String, *Output, StrgSize, Key, Counter)
            
            FileID = CreateFile(#PB_Any, File)
            If FileID 
              Result = WriteData(FileID, *Output, StrgSize)
              WriteString(FileID, ID$, #PB_Ascii)
              WriteQuad(FileID, Counter)
              CloseFile(FileID)
            EndIf
            
            FreeMemory(*Output)
          EndIf
          
        EndIf
        
      CompilerElse  
        
        ID = StringFingerprint("qAES", #PB_Cipher_SHA3, 256, #PB_Ascii)
        
        StrgSize = StringByteLength(String, #PB_Ascii) + 1
        If StrgSize
          
          *Output = AllocateMemory(StrgSize + 8)
          If *Output
            
            SmartCoder(#Binary, @String, *Output, StrgSize, Key, Counter)
            
            FileID = CreateFile(#PB_Any, File)
            If FileID 
              Result = WriteData(FileID, *Output, StrgSize)
              WriteString(FileID, ID$, #PB_Ascii)
              WriteQuad(FileID, Counter)
              CloseFile(FileID)
            EndIf
            
            FreeMemory(*Output)
          EndIf
  
        EndIf  
        
      CompilerEndIf
      
      ProcedureReturn Result
    EndProcedure  
    
    Procedure.s File2String(File.s, Key.s, KeyStretching.i=#False) 
      Define   *Input, *Output
      Define.q Counter
      Define.i FileID, FileSize, Result
      Define.s Output, ID$
      
      If KeyStretching
        Key = KeyStretching(Key, KeyStretching)
      EndIf 
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        ;{ Read ID & Counter
        FileSeek(FileID, FileSize - 21)
        ID$     = ReadString(FileID, #PB_Ascii, 13) 
        Counter = ReadQuad(FileID)
        FileSeek(FileID, 0)
        If Counter : FileSize - 21 : EndIf
        ;}
        
        If ID$ <> DESFingerprint("qAES", Str(Counter))
          CloseFile(FileID)
          qAES\Error = #ERROR_NOT_QAES_ENCRYPTED
          ProcedureReturn ""
        EndIf
        
        *Input  = AllocateMemory(FileSize)
        If *Input
  
          If ReadData(FileID, *Input, FileSize)
            
            CloseFile(FileID)
            
            *Output = AllocateMemory(FileSize)
            If *Output
              
              SmartCoder(#Binary, *Input, *Output, FileSize, Key, Counter)
              
              CompilerIf #PB_Compiler_Unicode
                Output = PeekS(*Output, FileSize, #PB_Unicode)
              CompilerElse
                Output = PeekS(*Output, FileSize, #PB_Ascii)
              CompilerEndIf
  
              FreeMemory(*Output)
            EndIf
            
          EndIf
          
          FreeMemory(*Input)
        EndIf
        
      Else
        qAES\Error = #ERROR_FILE_NOT_EXIST
        ProcedureReturn ""
      EndIf
      
      ProcedureReturn Output
    EndProcedure 
    
    Procedure.i EncodeFile(File.s, Key.s, outFile.s="", KeyStretching.i=#False) 
      Define   *Input, *Output
      Define.q Counter
      Define.i FileID, FileSize, Result
      Define.s ID$
      
      If KeyStretching
        Key = KeyStretching(Key, KeyStretching)
      EndIf 
      
      If OpenCryptRandom()
        CryptRandomData(@Counter, 8)
      Else
        RandomData(@Counter, 8)
      EndIf
      
      ID$ = DESFingerprint("qAES", Str(Counter))
      
      If outFile = ""
        outFile = File + ".aes"
      EndIf
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        *Input  = AllocateMemory(FileSize)
        If *Input
          
          If ReadData(FileID, *Input, FileSize)
            
            CloseFile(FileID)
            
            *Output = AllocateMemory(FileSize)
            If *Output
              
              SmartCoder(#Binary, *Input, *Output, FileSize, Key, Counter)
              
              FileID = CreateFile(#PB_Any, outFile)
              If FileID 
                Result = WriteData(FileID, *Output, FileSize)
                WriteString(FileID, ID$, #PB_Ascii)
                WriteQuad(FileID, Counter)
                CloseFile(FileID)
              EndIf
              
              FreeMemory(*Output)
            EndIf
            
          EndIf
          
          FreeMemory(*Input)
        EndIf
        
      Else
        qAES\Error = #ERROR_FILE_NOT_EXIST
        ProcedureReturn #False
      EndIf
      
      ProcedureReturn Result
    EndProcedure  
    
    Procedure.i DecodeFile(File.s, Key.s, outFile.s="", KeyStretching.i=#False) 
      Define   *Input, *Output
      Define.q Counter
      Define.i FileID, FileSize, Result
      Define.s ID$
      
      If KeyStretching
        Key = KeyStretching(Key, KeyStretching)
      EndIf 
      
      If outFile = ""
        If FileSize(File + ".aes") > 0
          outFile = File
          File    = File + ".aes"
        ElseIf LCase(Right(File, 4)) = ".aes"
          outFile = Left(File, Len(File) - 4)
        Else
          outFile = File
        EndIf
      EndIf
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        ;{ Read Counter
        FileSeek(FileID, FileSize - 21)
        ID$     = ReadString(FileID, #PB_Ascii, 13) 
        Counter = ReadQuad(FileID)
        FileSeek(FileID, 0)
        If Counter : FileSize - 21 : EndIf
        ;}
        
        If ID$ <> DESFingerprint("qAES", Str(Counter))
          CloseFile(FileID)
          qAES\Error = #ERROR_NOT_QAES_ENCRYPTED
          ProcedureReturn #False
        EndIf
        
        *Input  = AllocateMemory(FileSize)
        If *Input
  
          If ReadData(FileID, *Input, FileSize)
            
            CloseFile(FileID)
            
            *Output = AllocateMemory(FileSize)
            If *Output
              
              SmartCoder(#Binary, *Input, *Output, FileSize, Key, Counter)
              
              FileID = CreateFile(#PB_Any, outFile)
              If FileID 
                Result = WriteData(FileID, *Output, FileSize)
                CloseFile(FileID)
              EndIf
              
              FreeMemory(*Output)
            EndIf
            
          EndIf
          
          FreeMemory(*Input)
        EndIf
        
      Else
        qAES\Error = #ERROR_FILE_NOT_EXIST
        ProcedureReturn #False
      EndIf
      
      ProcedureReturn Result
    EndProcedure 
    
    Procedure.i IsCryptFile(File.s)   
      Define.q Counter
      Define.i FileID, FileSize, Result
      Define.s ID$
      
      If FileSize(File + ".aes") > 0 : File = File + ".aes" : EndIf
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        FileSeek(FileID, FileSize - 21)
        ID$     = ReadString(FileID, #PB_Ascii, 13) 
        Counter = ReadQuad(FileID)
        
        If ID$ = DESFingerprint("qAES", Str(Counter))
          Result = #True
        Else
          qAES\Error = #ERROR_NOT_QAES_ENCRYPTED
          Result = #False
        EndIf
        
        CloseFile(FileID)
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
  CompilerEndIf
  
  CompilerIf #Enable_LoadSaveCrypt
  
    Procedure.i SaveCryptImage(Image.i, File.s, Key.s, KeyStretching.i=#False)
      Define.i FileID, MemorySize, Result
      Define.q Counter
      Define.s ID$
      Define   *Buffer
      
      If IsImage(Image)
        
        If KeyStretching
          Key = KeyStretching(Key, KeyStretching)
        EndIf 
        
        If OpenCryptRandom()
          CryptRandomData(@Counter, 8)
        Else
          RandomData(@Counter, 8)
        EndIf
        
        ID$ = DESFingerprint("qAES", Str(Counter))
        
        *Buffer = EncodeImage(Image)
        If *Buffer
     
          MemorySize = MemorySize(*Buffer)
  
          SmartCoder(#Binary, *Buffer, *Buffer, MemorySize, Key, Counter)
         
          FileID = CreateFile(#PB_Any, File)
          If FileID 
            Result = WriteData(FileID, *Buffer, MemorySize)
            WriteString(FileID, ID$, #PB_Ascii)
            WriteQuad(FileID, Counter)
            CloseFile(FileID)
          EndIf
  
          FreeMemory(*Buffer)
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    Procedure.i LoadCryptImage(Image.i, File.s, Key.s, KeyStretching.i=#False) ; Use SaveCryptImage() or EncodeFile() to encrypt image
      Define   *Input, *Output
      Define.q Counter
      Define.i FileID, FileSize, Encrypted, Result
      Define.s ID$
      
      If KeyStretching
        Key = KeyStretching(Key, KeyStretching)
      EndIf 
      
      If FileSize(File + ".aes") > 0
        File + ".aes"
      EndIf
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        ;{ Read ID & Counter
        FileSeek(FileID, FileSize - 21)
        ID$     = ReadString(FileID, #PB_Ascii, 13) 
        Counter = ReadQuad(FileID)
        FileSeek(FileID, 0)
        
        If ID$ = DESFingerprint("qAES", Str(Counter))
          FileSize - 21
          Encrypted = #True
        Else  
          qAES\Error = #ERROR_NOT_QAES_ENCRYPTED
        EndIf 
        ;}
        
        *Input  = AllocateMemory(FileSize)
        If *Input
  
          If ReadData(FileID, *Input, FileSize)
            
            CloseFile(FileID)
            
            *Output = AllocateMemory(FileSize)
            If *Output
              
              If Encrypted
                SmartCoder(#Binary, *Input, *Output, FileSize, Key, Counter)
              EndIf
            
              Result = CatchImage(Image, *Output, FileSize)
  
              FreeMemory(*Output)
            EndIf
            
          EndIf
          
          FreeMemory(*Input)
        EndIf
        
      Else
        qAES\Error = #ERROR_FILE_NOT_EXIST
        ProcedureReturn #False
      EndIf
      
      ProcedureReturn Result
      
    EndProcedure
    
    
    Procedure.i SaveCryptXML(XML.i, File.s, Key.s, KeyStretching.i=#False)
      Define.i FileID, Size, Result
      Define.q Counter
      Define.s ID$
      Define   *Buffer
      
      If IsXML(XML)
        
        If KeyStretching
          Key = KeyStretching(Key, KeyStretching)
        EndIf 
        
        If OpenCryptRandom()
          CryptRandomData(@Counter, 8)
        Else
          RandomData(@Counter, 8)
        EndIf
        
        ID$ = DESFingerprint("qAES", Str(Counter))
        
        Size = ExportXMLSize(XML)
        If Size
          
          *Buffer = AllocateMemory(Size)
          If *Buffer
            
            If ExportXML(XML, *Buffer, Size)
              
              SmartCoder(#Binary, *Buffer, *Buffer, Size, Key, Counter)
              
              FileID = CreateFile(#PB_Any, File)
              If FileID 
                Result = WriteData(FileID, *Buffer, Size)
                WriteString(FileID, ID$, #PB_Ascii)
                WriteQuad(FileID, Counter)
                CloseFile(FileID)
              EndIf
              
            EndIf
            
            FreeMemory(*Buffer)
          EndIf
          
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    Procedure.i LoadCryptXML(XML.i, File.s, Key.s, KeyStretching.i=#False)     ; Use SaveCryptXML() or EncodeFile() to encrypt XML
      Define   *Buffer
      Define.q Counter
      Define.i FileID, FileSize, Encrypted, Result
      Define.s ID$
      
      If KeyStretching
        Key = KeyStretching(Key, KeyStretching)
      EndIf 
      
      If FileSize(File + ".aes") > 0
        File + ".aes"
      EndIf
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        ;{ Read ID & Counter
        FileSeek(FileID, FileSize - 21)
        ID$    = ReadString(FileID, #PB_Ascii, 13) 
        Counter = ReadQuad(FileID)
        FileSeek(FileID, 0)
        
        If ID$ = DESFingerprint("qAES", Str(Counter))
          FileSize - 21
          Encrypted = #True
        Else  
          qAES\Error = #ERROR_NOT_QAES_ENCRYPTED
        EndIf       
        ;}
        
        *Buffer  = AllocateMemory(FileSize)
        If *Buffer
  
          If ReadData(FileID, *Buffer, FileSize)
            
            CloseFile(FileID)
            
            If Encrypted
              SmartCoder(#Binary, *Buffer, *Buffer, FileSize, Key, Counter)
            EndIf
            
            Result = CatchXML(XML, *Buffer, FileSize)
            
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      Else
        qAES\Error = #ERROR_FILE_NOT_EXIST
        ProcedureReturn #False
      EndIf
      
      ProcedureReturn Result
      
    EndProcedure
    
    
    Procedure.i SaveCryptJSON(JSON.i, File.s, Key.s, KeyStretching.i=#False)
      Define.i FileID, Size, Result
      Define.q Counter
      Define.s ID$
      Define   *Buffer
      
      If IsJSON(JSON)
        
        If KeyStretching
          Key = KeyStretching(Key, KeyStretching)
        EndIf 
        
        If OpenCryptRandom()
          CryptRandomData(@Counter, 8)
        Else
          RandomData(@Counter, 8)
        EndIf
        
        ID$ = DESFingerprint("qAES", Str(Counter))
        
        Size = ExportJSONSize(JSON)
        If Size
          
          *Buffer = AllocateMemory(Size)
          If *Buffer
            
            If ExportJSON(JSON, *Buffer, Size)
              
              SmartCoder(#Binary, *Buffer, *Buffer, Size, Key, Counter)
              
              FileID = CreateFile(#PB_Any, File)
              If FileID 
                Result = WriteData(FileID, *Buffer, Size)
                WriteString(FileID, ID$, #PB_Ascii)
                WriteQuad(FileID, Counter)
                CloseFile(FileID)
              EndIf
              
            EndIf
            
            FreeMemory(*Buffer)
          EndIf
          
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    Procedure.i LoadCryptJSON(JSON.i, File.s, Key.s, KeyStretching.i=#False)   ; Use SaveCryptJSON() or EncodeFile() to encrypt XML
      Define   *Buffer
      Define.q Counter
      Define.i FileID, FileSize, Encrypted, Result
      Define.s ID$
      
      If KeyStretching
        Key = KeyStretching(Key, KeyStretching)
      EndIf 
      
      If FileSize(File + ".aes") > 0
        File + ".aes"
      EndIf
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        FileSize = Lof(FileID)
        
        ;{ Read ID & Counter
        FileSeek(FileID, FileSize - 21)
        ID$     = ReadString(FileID, #PB_Ascii, 13) 
        Counter = ReadQuad(FileID)
        FileSeek(FileID, 0)
        
        If ID$ = DESFingerprint("qAES", Str(Counter))
          FileSize - 21
          Encrypted = #True
        Else  
          qAES\Error = #ERROR_NOT_QAES_ENCRYPTED
        EndIf 
        ;}
        
        *Buffer  = AllocateMemory(FileSize)
        If *Buffer
  
          If ReadData(FileID, *Buffer, FileSize)
            
            CloseFile(FileID)
            
            If Encrypted
              SmartCoder(#Binary, *Buffer, *Buffer, FileSize, Key, Counter)
            EndIf             
            
            Result = CatchJSON(JSON, *Buffer, FileSize)
            
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      Else
        qAES\Error = #ERROR_FILE_NOT_EXIST
        ProcedureReturn #False
      EndIf
      
      ProcedureReturn Result
      
    EndProcedure
    
  CompilerEndIf
  
  ;- _____ Packer _____
  
  CompilerIf #Enable_CryptPacker

    Procedure.i AddCryptPackFile(Pack.i, File.s, Key.s, KeyStretching.i=#False) 
      Define   *Input, *Output
      Define.q Counter
      Define.i FileID, Size, Result
      Define.s ID$
      
      If KeyStretching
        Key = KeyStretching(Key, KeyStretching)
      EndIf 
      
      If OpenCryptRandom()
        CryptRandomData(@Counter, 8)
      Else
        RandomData(@Counter, 8)
      EndIf
      
      ID$ = DESFingerprint("qAES", Str(Counter))
      
      FileID = ReadFile(#PB_Any, File)
      If FileID
        
        Size = Lof(FileID)
        
        *Input  = AllocateMemory(Size)
        If *Input
          
          If ReadData(FileID, *Input, Size)
            
            CloseFile(FileID)
            
            *Output = AllocateMemory(Size + 21)
            If *Output
              
              SmartCoder(#Binary, *Input, *Output, Size, Key, Counter)
              
              PokeS(*Output + Size, ID$, 13, #PB_Ascii)
              PokeQ(*Output + Size + 13, Counter)
              
              Result = AddPackMemory(Pack, *Output, Size + 21, GetFilePart(File))

              FreeMemory(*Output)
            EndIf
            
          EndIf
          
          FreeMemory(*Input)
        EndIf
        
      Else
        qAES\Error = #ERROR_FILE_NOT_EXIST
        ProcedureReturn #False
      EndIf
      
      ProcedureReturn Result
    EndProcedure  
    
    Procedure.i UncompressCryptPackFile(Pack.i, File.s, Key.s, PackedFileName.s="", KeyStretching.i=#False) 
      Define   *Buffer
      Define.q Counter
      Define.i FileID, Size, Result
      Define.s ID$
      
      If KeyStretching
        Key = KeyStretching(Key, KeyStretching)
      EndIf 
      
      If PackedFileName = "" : PackedFileName = GetFilePart(File) : EndIf
      
      If ExaminePack(Pack)
        
        While NextPackEntry(Pack)
          
          If PackedFileName = PackEntryName(Pack)
            
            Size = PackEntrySize(Pack)
            
            *Buffer = AllocateMemory(Size)
            If *Buffer
              
              If UncompressPackMemory(Pack, *Buffer, Size) <> -1
                
                ID$     = PeekS(*Buffer + Size - 21, 13, #PB_Ascii)
                Counter = PeekQ(*Buffer + Size - 8)
                
                If ID$ = DESFingerprint("qAES", Str(Counter))
                  Size - 21
                  SmartCoder(#Binary, *Buffer, *Buffer, Size, Key, Counter)
                Else
                  qAES\Error = #ERROR_NOT_QAES_ENCRYPTED
                EndIf 

                FileID = CreateFile(#PB_Any, File)
                If FileID 
                  Result = WriteData(FileID, *Buffer, Size)
                  CloseFile(FileID)
                EndIf

              EndIf
              
              FreeMemory(*Buffer)
            EndIf
            
            Break
          EndIf
          
        Wend

      EndIf
      
      ProcedureReturn Result
    EndProcedure 
    
    
    Procedure.i AddCryptPackMemory(Pack.i, *Buffer, Size.i, Key.s, PackedFileName.s, KeyStretching.i=#False)
      Define   *Buffer, *Output
      Define.q Counter
      Define.i Size, Result
      Define.s ID$
      
      If KeyStretching
        Key = KeyStretching(Key, KeyStretching)
      EndIf 
      
      If OpenCryptRandom()
        CryptRandomData(@Counter, 8)
      Else
        RandomData(@Counter, 8)
      EndIf
      
      ID$ = DESFingerprint("qAES", Str(Counter))
      
      If *Buffer
        
        *Output = AllocateMemory(Size + 21)
        If *Output
          
          SmartCoder(#Binary, *Buffer, *Output, Size, Key, Counter)

          PokeS(*Output + Size, ID$, 13, #PB_Ascii)
          PokeQ(*Output + Size + 13, Counter)
          
          Result = AddPackMemory(Pack, *Output, Size + 21, PackedFileName)

          FreeMemory(*Output)
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    Procedure.i UncompressCryptPackMemory(Pack.i, *Buffer, Size.i, Key.s, PackedFileName.s="", KeyStretching.i=#False)
      Define   *Buffer
      Define.q Counter
      Define.i Size, Result
      Define.s ID$
      
      If KeyStretching
        Key = KeyStretching(Key, KeyStretching)
      EndIf 
      
      If *Buffer

        If UncompressPackMemory(Pack, *Buffer, Size, PackedFileName) <> -1
          
          ID$     = PeekS(*Buffer + Size - 21, 13, #PB_Ascii)
          Counter = PeekQ(*Buffer + Size - 8)
          
          If ID$ = DESFingerprint("qAES", Str(Counter))
            Size - 21
            SmartCoder(#Binary, *Buffer, *Buffer, Size, Key, Counter)
          Else
            qAES\Error = #ERROR_NOT_QAES_ENCRYPTED
          EndIf 

          Result = Size
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    

    Procedure.i AddCryptPackXML(Pack.i, XML.i, Key.s, PackedFileName.s, KeyStretching.i=#False)
      Define   *Buffer
      Define.q Counter
      Define.i Size, Result
      Define.s ID$
      
      If IsXML(XML)
      
        If KeyStretching
          Key = KeyStretching(Key, KeyStretching)
        EndIf 
        
        If OpenCryptRandom()
          CryptRandomData(@Counter, 8)
        Else
          RandomData(@Counter, 8)
        EndIf
        
        ID$ = DESFingerprint("qAES", Str(Counter))
        
        Size = ExportXMLSize(XML)
        If Size
          
          *Buffer = AllocateMemory(Size + 21)
          If *Buffer
            
            If ExportXML(XML, *Buffer, Size)
              
              SmartCoder(#Binary, *Buffer, *Buffer, Size, Key, Counter)
              
              PokeS(*Buffer + Size, ID$, 13, #PB_Ascii)
              PokeQ(*Buffer + Size + 13, Counter)
              
              Result = AddPackMemory(Pack, *Buffer, Size + 21, PackedFileName)
              
            EndIf
            
            FreeMemory(*Buffer)
          EndIf
          
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure  
    
    Procedure.i UncompressCryptPackXML(Pack.i, XML.i, Key.s, PackedFileName.s="", KeyStretching.i=#False)
      Define   *Buffer
      Define.q Counter
      Define.i Size, Result
      Define.s ID$
      
      If KeyStretching
        Key = KeyStretching(Key, KeyStretching)
      EndIf 
    
      If ExaminePack(Pack)
        
        While NextPackEntry(Pack)
          
          If PackedFileName = PackEntryName(Pack)
            
            Size = PackEntrySize(Pack)
            
            *Buffer = AllocateMemory(Size)
            If *Buffer
              
              If UncompressPackMemory(Pack, *Buffer, Size) <> -1
                
                ID$     = PeekS(*Buffer + Size - 21, 13, #PB_Ascii)
                Counter = PeekQ(*Buffer + Size - 8)
                
                If ID$ = DESFingerprint("qAES", Str(Counter))
                  Size - 21
                  SmartCoder(#Binary, *Buffer, *Buffer, Size, Key, Counter)
                Else
                  qAES\Error = #ERROR_NOT_QAES_ENCRYPTED
                EndIf 

                Result = CatchXML(XML, *Buffer, Size)
    
              EndIf
              
              FreeMemory(*Buffer)
            EndIf
            
            Break
          EndIf
          
        Wend
    
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    
    Procedure.i AddCryptPackJSON(Pack.i, JSON.i, Key.s, PackedFileName.s, KeyStretching.i=#False)
      Define   *Buffer
      Define.q Counter
      Define.i Size, Result
      Define.s ID$
      
      If IsJSON(JSON)
      
        If KeyStretching
          Key = KeyStretching(Key, KeyStretching)
        EndIf 
        
        If OpenCryptRandom()
          CryptRandomData(@Counter, 8)
        Else
          RandomData(@Counter, 8)
        EndIf
        
        ID$ = DESFingerprint("qAES", Str(Counter))
        
        Size = ExportJSONSize(JSON)
        If Size
          
          *Buffer = AllocateMemory(Size + 21)
          If *Buffer
            
            If ExportJSON(JSON, *Buffer, Size)
              
              SmartCoder(#Binary, *Buffer, *Buffer, Size, Key, Counter)
              
              PokeS(*Buffer + Size, ID$, 13, #PB_Ascii)
              PokeQ(*Buffer + Size + 13, Counter)
              
              Result = AddPackMemory(Pack, *Buffer, Size + 21, PackedFileName)
              
            EndIf
            
            FreeMemory(*Buffer)
          EndIf
          
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure  
    
    Procedure.i UncompressCryptPackJSON(Pack.i, JSON.i, Key.s, PackedFileName.s="", KeyStretching.i=#False)
      Define   *Buffer
      Define.q Counter
      Define.i Size, Result
      Define.s ID$
      
      If KeyStretching
        Key = KeyStretching(Key, KeyStretching)
      EndIf 
    
      If ExaminePack(Pack)
        
        While NextPackEntry(Pack)
          
          If PackedFileName = PackEntryName(Pack)
            
            Size = PackEntrySize(Pack)
            
            *Buffer = AllocateMemory(Size)
            If *Buffer
              
              If UncompressPackMemory(Pack, *Buffer, Size) <> -1
                
                ID$     = PeekS(*Buffer + Size - 21, 13, #PB_Ascii)
                Counter = PeekQ(*Buffer + Size - 8)
                
                If ID$ = DESFingerprint("qAES", Str(Counter))
                  Size - 21
                  SmartCoder(#Binary, *Buffer, *Buffer, Size, Key, Counter)
                Else
                  qAES\Error = #ERROR_NOT_QAES_ENCRYPTED
                EndIf 

                Result = CatchJSON(JSON, *Buffer, Size)
    
              EndIf
              
              FreeMemory(*Buffer)
            EndIf
            
            Break
          EndIf
          
        Wend
    
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    
    Procedure.i AddCryptPackImage(Pack.i, Image.i, Key.s, PackedFileName.s, KeyStretching.i=#False)
      Define   *Buffer, *Output
      Define.q Counter
      Define.i Size, Result
      Define.s ID$
      
      If IsImage(Image)
      
        If KeyStretching
          Key = KeyStretching(Key, KeyStretching)
        EndIf 
        
        If OpenCryptRandom()
          CryptRandomData(@Counter, 8)
        Else
          RandomData(@Counter, 8)
        EndIf
        
        ID$ = DESFingerprint("qAES", Str(Counter))
        
        *Buffer = EncodeImage(Image)
        If *Buffer
     
          Size = MemorySize(*Buffer)
          
          *Output = AllocateMemory(Size + 21)
          If *Output
            
            SmartCoder(#Binary, *Buffer, *Output, Size, Key, Counter)
            
            PokeS(*Output + Size, ID$, 13, #PB_Ascii)
            PokeQ(*Output + Size + 13, Counter)
           
            Result = AddPackMemory(Pack, *Output, Size + 21, PackedFileName)
            
            FreeMemory(*Output)
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      EndIf
      
      ProcedureReturn Result
    EndProcedure  
    
    Procedure.i UncompressCryptPackImage(Pack.i, Image.i, Key.s, PackedFileName.s="", KeyStretching.i=#False)
      Define   *Buffer
      Define.q Counter
      Define.i Size, Result
      Define.s ID$
      
      If KeyStretching
        Key = KeyStretching(Key, KeyStretching)
      EndIf 
    
      If ExaminePack(Pack)
        
        While NextPackEntry(Pack)
          
          If PackedFileName = PackEntryName(Pack)
            
            Size = PackEntrySize(Pack)
            
            *Buffer = AllocateMemory(Size)
            If *Buffer
              
              If UncompressPackMemory(Pack, *Buffer, Size) <> -1
                
                ID$     = PeekS(*Buffer + Size - 21, 13, #PB_Ascii)
                Counter = PeekQ(*Buffer + Size - 8)
                
                If ID$ = DESFingerprint("qAES", Str(Counter))
                  Size - 21
                  SmartCoder(#Binary, *Buffer, *Buffer, Size, Key, Counter)
                Else
                  qAES\Error = #ERROR_NOT_QAES_ENCRYPTED
                EndIf 

                Result = CatchImage(Image, *Buffer, Size)
    
              EndIf
              
              FreeMemory(*Buffer)
            EndIf
            
            Break
          EndIf
          
        Wend
    
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
    
    Procedure IsCryptPackFile(Pack.i, PackedFileName.s)
      Define   *Buffer
      Define.q Counter
      Define.i Size, Result
      Define.s ID$
      
      If ExaminePack(Pack)
        
        While NextPackEntry(Pack)
          
          If PackedFileName = PackEntryName(Pack)
            
            Size = PackEntrySize(Pack)
            
            *Buffer = AllocateMemory(Size)
            If *Buffer
              
              If UncompressPackMemory(Pack, *Buffer, Size) <> -1
                
                ID$     = PeekS(*Buffer + Size - 21, 13, #PB_Ascii)
                Counter = PeekQ(*Buffer + Size - 8)
                
                If ID$ = DESFingerprint("qAES", Str(Counter))
                  Result = #True
                Else
                  Result     = #False
                  qAES\Error = #ERROR_NOT_QAES_ENCRYPTED
                EndIf 
                
                FreeMemory(*Buffer)
              EndIf
              
            EndIf
            
          EndIf
          
        Wend
  
      EndIf
      
      ProcedureReturn Result
    EndProcedure
    
  CompilerEndIf
  
EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 1
  
  ;  1: String
  ;  2: File (only encrypt / decrypt)
  ;  3: String to File
  ;  4: SmartFileCoder
  ;  5: SmartFileCoder with CryptExtension
  ;  6: Check integrity
  ;  7: Protected Mode
  ;  8: Image
  ;  9: XML
  ; 10: JSON
  ; 11: Packer
  ; 12: Packer: XML
  ; 13: Packer: JSON
  ; 14: Packer: Image
  
  Enumeration 1
    #Window
    #ProgressBar
    #Image
  EndEnumeration
  
  #ProtectExtension$ = " [protected]"
  #CryptExtension$   = " [encrypted]"
  
  Key$  = "18qAES07PW67"
  
  CompilerSelect #Example
    CompilerCase 1 
      
      CompilerIf qAES::#Enable_BasicCoders
        
        Text$ = "This is a test text for the qAES-Module."
    
        encText$ = qAES::String(Text$, Key$) 
        Debug encText$
        
        decText$ = qAES::String(encText$, Key$)
        Debug decText$
        
      CompilerEndIf
      
    CompilerCase 2 
      
      CompilerIf qAES::#Enable_BasicCoders
        
        qAES::EncodeFile("PureBasic.jpg",  Key$) 
        ;qAES::DecodeFile("PureBasic.jpg", Key$)
        
      CompilerEndIf
      
    CompilerCase 3  
      
      CompilerIf qAES::#Enable_BasicCoders
        
        Text$ = "This is a test text for the qAES-Module."
        
        If qAES::String2File(Text$, "String.aes", Key$) 
          decText$ = qAES::File2String("String.aes", Key$)
          Debug decText$
        EndIf
        
      CompilerEndIf
      
    CompilerCase 4
      
      CompilerIf qAES::#Enable_SmartFileCoder
        qAES::SmartFileCoder("PureBasic.jpg", Key$)
        ;qAES::SmartFileCoder("PureBasic.jpg.aes", Key$)
      CompilerEndIf
    
    CompilerCase 5  
      
      CompilerIf qAES::#Enable_SmartFileCoder
        qAES::SmartFileCoder("PureBasic.jpg", Key$, #CryptExtension$)
        If qAES::IsEncrypted("PureBasic.jpg", Key$, #CryptExtension$)
          Debug "File is encrypted"
        Else
          Debug "File is not encrypted"
        EndIf
      CompilerEndIf
      
    CompilerCase 6
      
      CompilerIf qAES::#Enable_SmartFileCoder
        qAES::SmartFileCoder("PureBasic.jpg", Key$, #CryptExtension$)
        If qAES::CheckIntegrity("PureBasic.jpg", Key$, #CryptExtension$)
          Debug "File integrity succesfully checked"
        Else
          Debug "File hash not valid"
        EndIf 
      CompilerEndIf
      
    CompilerCase 7
      
      CompilerIf qAES::#Enable_SmartFileCoder
        qAES::SmartFileCoder("PureBasic.jpg", Key$, #ProtectExtension$, 18)  
        
        If qAES::IsEncrypted("PureBasic.jpg", Key$, #ProtectExtension$, 18)
          Debug "File is protected"
        Else
          Debug "File is not protected"
        EndIf
        
        If qAES::CheckIntegrity("PureBasic.jpg", Key$, #ProtectExtension$, 18)
          Debug "File integrity succesfully checked"
        Else
          Debug "File hash not valid"
        EndIf
      CompilerEndIf
      
    CompilerCase 8
      
      CompilerIf  qAES::#Enable_LoadSaveCrypt
        
        UseJPEGImageDecoder()
        
        ;qAES::EncodeFile("PureBasic.jpg", Key$)
        
        If LoadImage(#Image, "PureBasic.jpg")
          qAES::SaveCryptImage(#Image, "PureBasic.jpg.aes", Key$)
        EndIf
        
        If qAES::IsCryptFile("PureBasic.jpg")
          Debug "File is encrypted."
        Else
          Debug "File is not encrypted."
        EndIf
        
        If qAES::LoadCryptImage(#Image, "PureBasic.jpg", Key$)
          SaveImage(#Image, "DecryptedImage.jpg")
        EndIf

      CompilerEndIf
      
    CompilerCase 9
      
      CompilerIf  qAES::#Enable_LoadSaveCrypt
      
        #XML = 1
        
        NewList Shapes$()
        
        AddElement(Shapes$()): Shapes$() = "square"
        AddElement(Shapes$()): Shapes$() = "circle"
        AddElement(Shapes$()): Shapes$() = "triangle"
      
        If CreateXML(#XML)
          InsertXMLList(RootXMLNode(#XML), Shapes$())
          qAES::SaveCryptXML(#XML, "Shapes.xml", Key$)
          FreeXML(#XML)
        EndIf
        
        If qAES::LoadCryptXML(#XML, "Shapes.xml", Key$)
          Debug ComposeXML(#XML)
          FreeXML(#XML)
        EndIf
        
      CompilerEndIf
      
    CompilerCase 10
      
      CompilerIf  qAES::#Enable_LoadSaveCrypt
      
        #JSON = 1
        
        If CreateJSON(#JSON)
          Person.i = SetJSONObject(JSONValue(#JSON))
          SetJSONString(AddJSONMember(Person, "FirstName"), "John")
          SetJSONString(AddJSONMember(Person, "LastName"), "Smith")
          SetJSONInteger(AddJSONMember(Person, "Age"), 42)
          qAES::SaveCryptJSON(#JSON, "Person.json", Key$)
          FreeJSON(#JSON)
        EndIf
        
        If qAES::LoadCryptJSON(#JSON, "Person.json", Key$)
          Debug ComposeJSON(#JSON, #PB_JSON_PrettyPrint)
          FreeJSON(#JSON)
        EndIf
        
      CompilerEndIf
      
    CompilerCase 11
      
      CompilerIf qAES::#Enable_CryptPacker
        
        UseZipPacker()

        #Pack = 1
        
        If CreatePack(#Pack, "TestPB.zip", #PB_PackerPlugin_Zip)
          
          qAES::AddCryptPackFile(#Pack, "Test.txt", Key$)
          
          ClosePack(#Pack) 
        EndIf
        
        If OpenPack(#Pack, "TestPB.zip", #PB_PackerPlugin_Zip)
          
          
          If qAES::IsCryptPackFile(#Pack, "Test.txt")
            Debug "Packed file is encrypted."
          Else
            Debug "Packed file is not encrypted."
          EndIf
          
          qAES::UncompressCryptPackFile(#Pack, "Encrypted.txt", Key$, "Test.txt")
          
          ClosePack(#Pack) 
        EndIf
      
      CompilerEndIf
      
    CompilerCase 12
      
      CompilerIf qAES::#Enable_CryptPacker
        
        UseZipPacker()

        #Pack = 1
        #XML  = 1
        
        NewList Shapes$()
        
        AddElement(Shapes$()): Shapes$() = "square"
        AddElement(Shapes$()): Shapes$() = "circle"
        AddElement(Shapes$()): Shapes$() = "triangle"
      
        If CreateXML(#XML)
          InsertXMLList(RootXMLNode(#XML), Shapes$())
          
          If CreatePack(#Pack, "TestXML.zip", #PB_PackerPlugin_Zip)
            
            qAES::AddCryptPackXML(#Pack, #XML, Key$, "Shapes.xml")
            
            ClosePack(#Pack) 
          EndIf

          FreeXML(#XML)
        EndIf
        
        If OpenPack(#Pack, "TestXML.zip", #PB_PackerPlugin_Zip)
          
          If qAES::UncompressCryptPackXML(#Pack, #XML, Key$, "Shapes.xml")
            Debug ComposeXML(#XML)
            FreeXML(#XML)
          EndIf
          
          ClosePack(#Pack) 
        EndIf
        
      CompilerEndIf
      
    CompilerCase 13
      
      CompilerIf qAES::#Enable_CryptPacker
        
        UseZipPacker()

        #Pack = 1  
        #JSON = 1
        
        If CreateJSON(#JSON)
          
          Person.i = SetJSONObject(JSONValue(#JSON))
          SetJSONString(AddJSONMember(Person, "FirstName"), "John")
          SetJSONString(AddJSONMember(Person, "LastName"), "Smith")
          SetJSONInteger(AddJSONMember(Person, "Age"), 42)
          
          If CreatePack(#Pack, "TestJSON.zip", #PB_PackerPlugin_Zip) 
            qAES::AddCryptPackJSON(#Pack, #JSON, Key$, "Person.json")
            ClosePack(#Pack) 
          EndIf
          
          FreeJSON(#JSON)
        EndIf
        
        If OpenPack(#Pack, "TestJSON.zip", #PB_PackerPlugin_Zip)
          
          If qAES::UncompressCryptPackJSON(#Pack, #JSON, Key$, "Person.json")
            Debug ComposeJSON(#JSON, #PB_JSON_PrettyPrint)
            FreeJSON(#JSON)
          EndIf
          
          ClosePack(#Pack) 
        EndIf
        
      CompilerEndIf
      
    CompilerCase 14
      
      CompilerIf qAES::#Enable_CryptPacker
        
        UseJPEGImageDecoder()
        UseZipPacker()  

        #Pack  = 1 
        
        If LoadImage(#Image, "PureBasic.jpg")
          
          If CreatePack(#Pack, "TestImage.zip", #PB_PackerPlugin_Zip)
            qAES::AddCryptPackImage(#Pack, #Image, Key$, "PureBasic.jpg")
            ClosePack(#Pack) 
          EndIf
        
        EndIf
        
        If OpenPack(#Pack, "TestImage.zip", #PB_PackerPlugin_Zip)
          
          If qAES::UncompressCryptPackImage(#Pack, #Image, Key$, "PureBasic.jpg")
            SaveImage(#Image, "DecryptedImage.jpg")
          EndIf
          
          ClosePack(#Pack) 
        EndIf

      CompilerEndIf
      
  CompilerEndSelect

CompilerEndIf

; IDE Options = PureBasic 5.71 beta 2 LTS (Windows - x86)
; CursorPosition = 2139
; FirstLine = 260
; Folding = nBC9fAqChAIAIhE-
; Markers = 537,751
; EnableXP
; DPIAware