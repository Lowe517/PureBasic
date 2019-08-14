﻿;/ ==========================
;/ =    PackExModule.pbi    =
;/ ==========================
;/
;/ [ PB V5.7x / 64Bit / All OS]
;/
;/ Encryption based on code of Werner Albus - www.nachtoptik.de
;/ 
;/ © 2019 Thorsten1867 (08/2019)
;/

; [ Extended Packer ]

; - Add or replace a file to an opened archive
; - Remove a file from an open archive
; - Move files back to the archive or update them when the archive is closed. [#MoveBack/#Update]
; - Add encrypted files to the archive or or decrypt files during unpacking
; - Save XML, JSON and Images directly in the archive and load them directly from the archive
; - Add sound, music or sprite files to the archiv and load them directly from the archive


; Last Update: 


;{ ===== MIT License =====
;
; Copyright (c) 2019 Thorsten Hoeppner
; Copyright (c) 2019 Werner Albus - www.nachtoptik.de
;
; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:
; 
; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.
;}


;{ _____ PackEx - Commands _____

; PackEx::AddFile()          - similar to AddPackFile()
; PackEx::AddImage()         - similar to SaveImage(), but for archive
; PackEx::AddJSON()          - similar to SaveJSON(), but for archive
; PackEx::AddMemory()        - similar to AddPackMemory()
; PackEx::AddXML()           - similar to SaveXML(), but for archive
; PackEx::Close()            - similar to ClosePack()  [#MoveBack/#Update]
; PackEx::Create()           - similar to CreatePack()
; PackEx::DecompressFile()   - similar to UncompressPackFile()
; PackEx::DecompressImage()  - similar to LoadImage(), but for archive
; PackEx::DecompressJSON()   - similar to LoadJSON(), but for archive
; PackEx::DecompressMemory() - similar to UncompressPackMemory()
; PackEx::DecompressMusic()  - similar to LoadMusic(), but for archive
; PackEx::DecompressSound()  - similar to LoadSound(), but for archive
; PackEx::DecompressXML()    - similar to LoadXML(), but for archive
; PackEx::IsEncrypted()      - checks if the packed file is encrypted
; PackEx::Open()             - similar to OpenPack()
; PackEx::RemoveFile()       - remove file from archive
; PackEx::SetSalt()          - add your own salt
; PackEx::CreateSecureKey()  - use secure keys to make brute force attacks more difficult

;}


DeclareModule PackEx
  
  ;- ==================================
	;-   DeclareModule - Constants
	;- ==================================
  
  EnumerationBinary 
    #Create
    #Open
    #Add
    #Replace
    #Remove
    #Memory
    #File
    #XML
    #JSON
    #IMAGE
    #MoveBack
    #Update
  EndEnumeration
  
  Enumeration 1
    #ERROR_CANT_CREATE_COUNTER
    #ERROR_CANT_CREATE_PACK
    #ERROR_CANT_OPEN_PACK
    #ERROR_CANT_UNCOMPRESS_FILE
    #ERROR_CANT_UNCOMPRESS_PACKMEMORY
    #ERROR_FILE_NOT_EXIST
    #ERROR_CANT_OPEN_FILE
    #ERROR_ENCODING_FAILS
    #ERROR_NOT_ENCRYPTED
    #ERROR_REBUILD_FAILED
    #ERROR_INTEGRITY_CORRUPTED
  EndEnumeration
  
  ;- ==================================
	;-   DeclareModule
  ;- ==================================
  
  Declare.i AddFile(Pack.i, File.s, PackedFileName.s, Key.s="")
  Declare.i AddImage(Pack.i, Image.i, PackedFileName.s, Key.s="")
  Declare.i AddJSON(Pack.i, JSON.i, PackedFileName.s, Key.s="")
  Declare.i AddMemory(Pack.i, *Buffer, Size.i, PackedFileName.s, Key.s="")
  Declare.i AddXML(Pack.i, XML.i, PackedFileName.s, Key.s="")
  Declare   Close(Pack.i, Flags.i=#False)
  Declare.i Create(Pack.i, File.s, Plugin.i=#PB_PackerPlugin_Zip, Level.i=9)
  Declare.i DecompressFile(Pack.i, File.s, PackedFileName.s, Key.s="")
  Declare.i DecompressImage(Pack.i, Image.i, PackedFileName.s, Key.s="")
  Declare.i DecompressJSON(Pack.i, JSON.i, PackedFileName.s, Key.s="", Flags.i=#False)
  Declare.i DecompressMemory(Pack.i, *Buffer, Size.i, PackedFileName.s, Key.s="")
  Declare.i DecompressMusic(Pack.i, Music.i, PackedFileName.s, Key.s="", Flags.i=#False)
  Declare.i DecompressSound(Pack.i, Sound.i, PackedFileName.s, Key.s="")
  Declare.i DecompressXML(Pack.i, XML.i, PackedFileName.s, Key.s="", Flags.i=#False, Encoding.i=#PB_UTF8)
  Declare.i IsEncrypted(Pack.i, PackedFileName.s)
  Declare.i Open(Pack.i, File.s, Plugin.i=#PB_PackerPlugin_Zip)
  Declare.i RemoveFile(Pack.i, PackedFileName.s) 
  Declare   SetSalt(String.s)
  Declare.s CreateSecureKey(Key.s, Loops.i=2048, ProgressBar.i=#PB_Default)
  
EndDeclareModule

Module PackEx
  
  EnableExplicit
  
  UseSHA3Fingerprint()
  
  ;- ==================================
	;-   Module - Constants
	;- ==================================
  
  Enumeration
    #Binary
    #Ascii
    #Unicode
  EndEnumeration

  #qAES  = 113656983
  #Salt$ = "t8690352cj2p1ch7fgw34u&=)?=)/%&§/&)=?(otmq09745$%()=)&%"
  
  ;- ==================================
  ;-   Module - Structure
	;- ==================================
  
  Global Error.i
  
  Structure AES_Structure         ;{ qAES\...
    Salt.s
    KeyStretching.i
    Loops.i
    Hash.s
  EndStructure ;}
  Global qAES.AES_Structure
  
  Structure PackEx_File_Structure ;{ PackEx()\Files('file')...
    ID.i
    Size.q
    Compressed.q
    Type.i
    Path.s
    Key.s
    Hash.s
    Flags.i
  EndStructure ;}
  
  Structure PackEx_Structure      ;{ PackEx('pack')\...
    ID.i
    Mode.i
    File.s
    Plugin.i
    Level.i
    TempDir.s
    Map Files.PackEx_File_Structure()
  EndStructure ;}
  Global NewMap PackEx.PackEx_Structure()
    
  ;- ==================================
	;-   Module - Internal Procedures
	;- ==================================
  
	Procedure.q GetCounter_()
	  Define.q Counter
	  
	  If OpenCryptRandom()
      CryptRandomData(@Counter, 8)
    Else
      RandomData(@Counter, 8)
    EndIf
    
    ProcedureReturn Counter
	EndProcedure  
	
	Procedure.s KeyStretching_(Key.s, Loops.i, ProgressBar.i=#PB_Default)
    ; Author Werner Albus - www.nachtoptik.de
    Define.i i, Timer
    Define.s Salt$
    
    If qAES\Salt = "" 
	    Salt$ = "59#ö#3:_,.45ß$/($(/=)?=JjB$§/(&=$?=)((/&)%WE/()T&%z#'"
	  Else  
	    Salt$ = qAES\Salt + "59#ö#3:_,.45ß$/($(/=)?=JjB$§/(&=$?=)((/&)%WE/()T&%z#'"
	  EndIf
    
    If IsGadget(ProgressBar)
      Timer = ElapsedMilliseconds()
      SetGadgetState(ProgressBar, 0)
      While WindowEvent() : Wend
    EndIf
    
    For i=1 To Loops
      
      Key = ReverseString(Salt$) + Key + Salt$ + ReverseString(Key)
      Key = Fingerprint(@Key, StringByteLength(Key), #PB_Cipher_SHA3, 512)
      
      If IsGadget(ProgressBar)
        If ElapsedMilliseconds() > Timer + 100
          SetGadgetState(ProgressBar, 100 * i / Loops)
          Timer = ElapsedMilliseconds()
          While WindowEvent() : Wend
        EndIf
      EndIf
      
    Next
    
    Key = ReverseString(Key) + Salt$ + Key + ReverseString(Key)
    Key = Fingerprint(@Key, StringByteLength(Key), #PB_Cipher_SHA3, 512) ; Finalize
    
    If IsGadget(ProgressBar)
      SetGadgetState(ProgressBar, 100)
      While WindowEvent() : Wend
    EndIf
    
    ProcedureReturn Key
  EndProcedure
  
  
	Procedure.i SmartCoder(Mode.i, *Input.word, *Output.word, Size.q, Key.s, CounterKey.q=0, CounterAES.q=0)
	  ; Author: Werner Albus - www.nachtoptik.de (No warranty whatsoever - Use at your own risk)
    ; CounterKey: If you cipher a file blockwise, always set the current block number with this counter (consecutive numbering).
    ; CounterAES: This counter will be automatically used by the coder, but you can change the startpoint.
	  Define.i i, ii, iii, cStep
	  Define.q Rounds, Remaining
	  Define.s Hash$, Salt$
	  Define   *aRegister.ascii, *wRegister.word, *aBufferIn.ascii, *aBufferOut.ascii, *qBufferIn.quad, *qBufferOut.quad
	  Static   FixedKey${64}
	  Static   Dim Register.q(3)
	  
	  If qAES\Salt = ""
	    Salt$ = #Salt$
	  Else
	    Salt$ = qAES\Salt + #Salt$   
	  EndIf
	  
	  Hash$     = Salt$ + Key + Str(CounterKey) + ReverseString(Salt$)
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
	          Error = #ERROR_ENCODING_FAILS
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
            Error = #ERROR_ENCODING_FAILS
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
            Error = #ERROR_ENCODING_FAILS
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
	          Error = #ERROR_ENCODING_FAILS
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
	          Error = #ERROR_ENCODING_FAILS
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
	
	
	Procedure   EncodeHash_(Hash.s, Counter.q, *Hash)
    Define.i i
    
    Static Dim Hash.q(31)
    
    For i=0 To 31
      PokeA(@Hash(0) + i, Val("$" + PeekS(@Hash + i * SizeOf(character) << 1, 2)))
    Next
    
    SmartCoder(#Binary, @Hash(0), *Hash, 32, Str(Counter))
    
  EndProcedure

  Procedure.s DecodeHash_(Counter.q, *Hash, FreeMemory.i=#True)
    Define.i i
    Define.s Hash$
    
    Static Dim Hash.q(31)
    
    If *Hash
      
      SmartCoder(#Binary, *Hash, @Hash(0), 32, Str(Counter))
      
      For i = 0 To 31
        Hash$ + RSet(Hex(PeekA(@Hash(0) + i)), 2, "0")
      Next i
      
      If FreeMemory : FreeMemory(*Hash) : EndIf
    EndIf
    
    ProcedureReturn LCase(Hash$)
  EndProcedure
  
  
	Procedure.i DecryptMemory_(*Buffer, Size.i, Key.s)
	  Define.q Counter, qAES_ID
	  
	  Counter   = PeekQ(*Buffer + Size - 8)
    qAES_ID   = PeekQ(*Buffer + Size - 16)
    qAES\Hash = DecodeHash_(Counter, *Buffer + Size - 48, #False)
    
    SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(Counter))
    
    If qAES_ID = #qAES
      
      Size - 48
      
      SmartCoder(#Binary, *Buffer, *Buffer, Size, Key, Counter)
      
      If qAES\Hash <> Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
        Error = #ERROR_INTEGRITY_CORRUPTED
        qAES\Hash  = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
        ProcedureReturn #False
      EndIf
      
    Else
      Error = #ERROR_NOT_ENCRYPTED
    EndIf 
    
	  ProcedureReturn #True
	EndProcedure
	
	Procedure.i AddCryptMemory_(PackID, *Buffer, Size.i, PackedFileName.s, Key.s)
	  Define.i Size, Result
	  Define.q Counter,qAES_ID = #qAES
	  Define   *Buffer, *Hash

	  Counter = GetCounter_()
    
    qAES\Hash = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
    *Hash = AllocateMemory(32)
    If *Hash : EncodeHash_(qAES\Hash, Counter, *Hash) : EndIf
    
    SmartCoder(#Binary, *Buffer, *Buffer, Size, Key, Counter)
    SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(Counter))
    
    CopyMemory(*Hash, *Buffer + Size, 32)
    PokeQ(*Buffer + Size + 32, qAES_ID)
    PokeQ(*Buffer + Size + 40, Counter)

    Size + 48
    
    Result = AddPackMemory(PackID, *Buffer, Size, PackedFileName)

    ProcedureReturn Result
	EndProcedure
	
	Procedure.i AddCryptFile_(PackID, File.s, PackedFileName.s, Key.s) 
	  Define.i FileID, Size, Result
    Define.q Counter, cCounter, checkID, qAES_ID = #qAES
    Define   *Buffer, *Hash
    
    Counter = GetCounter_()
    
    FileID = ReadFile(#PB_Any, File)
    If FileID
      
      Size = Lof(FileID)
      If Size > 0
        
        *Buffer  = AllocateMemory(Size + 48)
        If *Buffer

          If ReadData(FileID, *Buffer, Size)
            
            CloseFile(FileID)
          
            checkID  = PeekQ(*Buffer + Size - 16)
            cCounter = PeekQ(*Buffer + Size - 8)
            SmartCoder(#Binary, @checkID, @checkID, 8, Str(cCounter))
            
            If checkID <> #qAES
              
              qAES\Hash = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
              *Hash = AllocateMemory(32)
              If *Hash : EncodeHash_(qAES\Hash, Counter, *Hash) : EndIf
              
              SmartCoder(#Binary, *Buffer, *Buffer, Size, Key, Counter)
              SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(Counter))
              
              CopyMemory(*Hash, *Buffer + Size, 32)
              PokeQ(*Buffer + Size + 32, qAES_ID)
              PokeQ(*Buffer + Size + 40, Counter)
              
              Size + 48
            EndIf
            
            Result = AddPackMemory(PackID, *Buffer, Size, PackedFileName)
            
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      EndIf
      
    EndIf  
    
    If Result : ProcedureReturn Size : EndIf
    
	  ProcedureReturn #False
	EndProcedure
	
	
	Procedure.i AddMemory2Pack_(*Buffer, Size.i, PackedFileName.s, Key.s) ; only OpenPack()
	  Define.i PackID, PackEntrySize, Size, pResult, Result
	  Define.s PackFile, PackEntryName
	  Define   *Buffer
	  
	  PackFile = PackEx()\TempDir + GetFilePart(PackEx()\File)
	  
	  PackID = CreatePack(#PB_Any, PackFile, PackEx()\Plugin, PackEx()\Level)
	  If PackID
	    
	    If ExaminePack(PackEx()\ID)
	      
	      Result = #True
	      
	      While NextPackEntry(PackEx()\ID)
	        
	        PackEntryName = PackEntryName(PackEx()\ID)

	        If PackEntryName = PackedFileName ;{ Ignore PackedFileName
	          Continue ;}
	        Else                              ;{ Copy other files
	          
	          PackEntrySize = PackEntrySize(PackEx()\ID)
	          
	          *Buffer = AllocateMemory(PackEntrySize)
	          If *Buffer
	            
	            If UncompressPackMemory(PackEx()\ID, *Buffer, PackEntrySize, PackEntryName) <> -1
	              pResult = AddPackMemory(PackID, *Buffer, PackEntrySize, PackEntryName)
	              If Not pResult : Result = #False : EndIf
	            Else
	              Result = #False
                Error  = #ERROR_CANT_UNCOMPRESS_PACKMEMORY
              EndIf
              
	            FreeMemory(*Buffer)
	          EndIf
  	        ;}
	        EndIf
	        
	      Wend
	      
	      ClosePack(PackEx()\ID)
	    EndIf
	    
	    ; Add *Buffer to new pack
	    If Key
	      pResult = AddCryptMemory_(PackID, *Buffer, Size, PackedFileName, Key)
	    Else
	      pResult = AddPackMemory(PackID, *Buffer, Size, PackedFileName)
	    EndIf
	    
	    If Not pResult : Result = #False : EndIf
	    
	    ClosePack(PackID)
	  EndIf
	  
	  If Result : CopyFile(PackFile, PackEx()\File) : EndIf
	  
	  PackEx()\ID = OpenPack(#PB_Any, PackEx()\File, PackEx()\Plugin)
	  
	  If Result : ProcedureReturn pResult : EndIf
 
	  ProcedureReturn #False
	EndProcedure
	
	Procedure.i AddFile2Pack_(File.s, PackedFileName.s, Key.s)            ; only OpenPack()
	  Define.i PackID, PackEntrySize, Size, pResult, Result
	  Define.s PackFile, PackEntryName
	  Define   *Buffer
	  
	  PackFile = PackEx()\TempDir + GetFilePart(PackEx()\File)
	  
	  PackID = CreatePack(#PB_Any, PackFile, PackEx()\Plugin, PackEx()\Level)
	  If PackID
	    
	    If ExaminePack(PackEx()\ID)
	      
	      Result = #True
	      
	      While NextPackEntry(PackEx()\ID)
	        
	        PackEntryName = PackEntryName(PackEx()\ID)

	        If PackEntryName = PackedFileName ;{ Ignore PackedFileName
	          Continue ;}
	        Else                              ;{ Copy other files
	          
	          PackEntrySize = PackEntrySize(PackEx()\ID)
	          
	          *Buffer = AllocateMemory(PackEntrySize)
	          If *Buffer
	            
	            If UncompressPackMemory(PackEx()\ID, *Buffer, PackEntrySize, PackEntryName) <> -1
	              pResult = AddPackMemory(PackID, *Buffer, PackEntrySize, PackEntryName)
	              If Not pResult : Result = #False : EndIf
	            Else
	              Result = #False
                Error  = #ERROR_CANT_UNCOMPRESS_PACKMEMORY
              EndIf
              
	            FreeMemory(*Buffer)
	          EndIf
  	        ;}
	        EndIf
	        
	      Wend
	      
	      ClosePack(PackEx()\ID)
	    EndIf
	    
	    ; Add file to new pack
	    If Key
	      pResult = AddCryptFile_(PackID, File, PackedFileName, Key)
	      Size = pResult
	    Else
	      pResult = AddPackFile(PackID, File, PackedFileName)
	      Size = FileSize(File)
	    EndIf
	    
	    If Not pResult : Result = #False : EndIf
	    
	    ClosePack(PackID)
	  EndIf
	  
	  If Result : CopyFile(PackFile, PackEx()\File) : EndIf
	  
	  PackEx()\ID = OpenPack(#PB_Any, PackEx()\File, PackEx()\Plugin)
	  
	  If Result : ProcedureReturn Size : EndIf
	  
	  ProcedureReturn #False
	EndProcedure

	Procedure.i RemoveFile_(PackedFileName.s)                             ; only OpenPack()
	  Define.i PackID, PackEntrySize, Size, pResult, Result
	  Define.s PackFile, PackEntryName
	  Define   *Buffer
	  
	  If PackEx()\Mode = #Create : ProcedureReturn #False : EndIf 
	  
	  PackFile = PackEx()\TempDir + GetFilePart(PackEx()\File)
	  
	  PackID = CreatePack(#PB_Any, PackFile, PackEx()\Plugin, PackEx()\Level)
	  If PackID
	    
	    If ExaminePack(PackEx()\ID)
	      
	      Result = #True
	      
	      While NextPackEntry(PackEx()\ID)
	        
	        PackEntryName = PackEntryName(PackEx()\ID)

	        If PackEntryName = PackedFileName ;{ Ignore PackedFileName
	          Continue ;}
	        Else                              ;{ Copy other files
	          
	          PackEntrySize = PackEntrySize(PackEx()\ID)
	          
	          *Buffer = AllocateMemory(PackEntrySize)
	          If *Buffer
	            
	            If UncompressPackMemory(PackEx()\ID, *Buffer, PackEntrySize, PackEntryName) <> -1
	              pResult = AddPackMemory(PackID, *Buffer, PackEntrySize, PackEntryName)
	              If Not pResult : Result = #False : EndIf
	            Else
	              Result = #False
                Error  = #ERROR_CANT_UNCOMPRESS_PACKMEMORY
              EndIf
              
	            FreeMemory(*Buffer)
	          EndIf
  	        ;}
	        EndIf
	        
	      Wend
	      
	      ClosePack(PackEx()\ID)
	    EndIf
	    
	    ClosePack(PackID)
	  EndIf
	  
	  If Result : CopyFile(PackFile, PackEx()\File) : EndIf
	  
	  PackEx()\ID = OpenPack(#PB_Any, PackEx()\File, PackEx()\Plugin)
	  
	  If Result : ProcedureReturn #True : EndIf
	  
	  ProcedureReturn #False
	EndProcedure
	
	
	Procedure   ReadContent_()
	  
	  ClearMap(PackEx()\Files())
    
    If ExaminePack(PackEx()\ID)
      While NextPackEntry(PackEx()\ID)
        If AddMapElement(PackEx()\Files(), PackEntryName(PackEx()\ID))
          PackEx()\Files()\Size       = PackEntrySize(PackEx()\ID, #PB_Packer_UncompressedSize)
          PackEx()\Files()\Compressed = PackEntrySize(PackEx()\ID, #PB_Packer_CompressedSize)
          PackEx()\Files()\Type       = PackEntryType(PackEx()\ID)
        EndIf
      Wend
    EndIf
    
	EndProcedure
	
	Procedure.i TempDir_(Pack.i)
	  
	  PackEx()\TempDir = GetTemporaryDirectory() + "PackEx" + RSet(Str(Pack), 4, "0") + #PS$
    If CreateDirectory(PackEx()\TempDir)
      ProcedureReturn #True
    EndIf
	  
	EndProcedure
	
	
  ;- ==================================
	;-   Module - Declared Procedures
	;- ==================================
	
  Procedure.s CreateSecureKey(Key.s, Loops.i=2048, ProgressBar.i=#PB_Default)
    ProcedureReturn KeyStretching_(Key, Loops, ProgressBar)
  EndProcedure
  
	
	Procedure.i IsEncrypted(Pack.i, PackedFileName.s)
    Define.i Size, Result = -1
    Define.q Counter, qAES_ID
    Define   *Buffer  
   
    If FindMapElement(PackEx(), Str(Pack))
      
      If FindMapElement(PackEx()\Files(), PackedFileName)
        
        Size = PackEx()\Files()\Size
        
        *Buffer = AllocateMemory(Size)
        If *Buffer
          
          If UncompressPackMemory(PackEx()\ID, *Buffer, Size, PackedFileName) <> -1
           
            qAES_ID = PeekQ(*Buffer + Size - 16)
            Counter = PeekQ(*Buffer + Size - 8)
            SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(Counter))
            
            If qAES_ID = #qAES
              Result = #True
            Else
              Result = #False
            EndIf 
           
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  
	Procedure.i Create(Pack.i, File.s, Plugin.i=#PB_PackerPlugin_Zip, Level.i=9)
	  
	  If Pack = #PB_Any
      Pack = 1 : While FindMapElement(PackEx(), Str(Pack)) : Pack + 1 : Wend
    EndIf
	  
    If AddMapElement(PackEx(), Str(Pack))
      
      PackEx()\ID     = CreatePack(#PB_Any, File, Plugin, Level)
      PackEx()\Plugin = Plugin
      PackEx()\Level  = Level
      PackEx()\File   = File
      PackEx()\Mode   = #Create
      
      TempDir_(Pack)
      
      ProcedureReturn PackEx()\ID
    EndIf
    
  EndProcedure
	
  Procedure.i Open(Pack.i, File.s, Plugin.i=#PB_PackerPlugin_Zip)
    
    If Pack = #PB_Any
      Pack = 1 : While FindMapElement(PackEx(), Str(Pack)) : Pack + 1 : Wend
    EndIf
    
    If AddMapElement(PackEx(), Str(Pack))
      
      PackEx()\ID     = OpenPack(#PB_Any, File, Plugin)
      PackEx()\Plugin = Plugin
      PackEx()\File   = File
      PackEx()\Mode   = #Open
      
      ReadContent_()
      
      TempDir_(Pack)
      
      ProcedureReturn PackEx()\ID
    EndIf
    
  EndProcedure
  

  Procedure.i AddFile(Pack.i, File.s, PackedFileName.s, Key.s="")
    Define.i FileID, Size
    
    If FindMapElement(PackEx(), Str(Pack))
      
      If PackEx()\Mode = #Open
        
        Size = AddFile2Pack_(File, PackedFileName, Key)
        
      Else    ; #Create
        
        If Key ; encrypt & pack file
          Size = AddCryptFile_(PackEx()\ID, File, PackedFileName, Key)
        Else   ; pack file
          If AddPackFile(PackEx()\ID, File, PackedFileName)
            Size = FileSize(File)
          EndIf
        EndIf
        
      EndIf
      
      If Size
        PackEx()\Files(PackedFileName)\Size = Size
        PackEx()\Files(PackedFileName)\Type = #PB_Packer_File
        PackEx()\Files(PackedFileName)\Flags | #File
      EndIf
    
    EndIf
    
    ProcedureReturn Size
  EndProcedure
  
  Procedure.i DecompressFile(Pack.i, File.s, PackedFileName.s, Key.s="")
    Define.i FileID, Size, Result = -1
    Define   *Buffer
    
    If FindMapElement(PackEx(), Str(Pack))
      
      If Key  ;{ decrypt & pack file

        If FindMapElement(PackEx()\Files(), PackedFileName)
          
          Size = PackEx()\Files()\Size
          
          *Buffer = AllocateMemory(Size)
          If *Buffer
            
            If UncompressPackMemory(PackEx()\ID, *Buffer, Size, PackedFileName) <> -1
              
              If DecryptMemory_(*Buffer, Size, Key)
                
                Size - 48
              
                FileID = CreateFile(#PB_Any, File)
                If FileID 
                  If WriteData(FileID, *Buffer, Size)
                    Result = Size
                  EndIf
                  CloseFile(FileID)
                EndIf
                
              EndIf
              
              If Result : PackEx()\Files(PackedFileName)\Key = Key : EndIf
              
            Else
              Error = #ERROR_CANT_UNCOMPRESS_PACKMEMORY  
            EndIf
            
            FreeMemory(*Buffer)
          EndIf

        EndIf
        ;}
      Else    ;{ pack file
        
        Result = UncompressPackFile(PackEx()\ID, File, PackedFileName)
        ;}
      EndIf
      
      If Result
        PackEx()\Files(PackedFileName)\Path = GetPathPart(File)
        PackEx()\Files(PackedFileName)\Flags | #Open | #File
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure.i AddMemory(Pack.i, *Buffer, Size.i, PackedFileName.s, Key.s="") 
    Define.i Result
    Define.q Counter, Hash, qAES_ID = #qAES
    Define   *Buffer, *Output
    
    If FindMapElement(PackEx(), Str(Pack))
      
      If Key  ;{ encrypt & pack file

        Counter = GetCounter_()
        
        If Size > 0
         
          *Output  = AllocateMemory(Size + 48)
          If *Output
            
            If PackEx()\Mode = #Open
              Result = AddMemory2Pack_(*Output, Size, PackedFileName, Key)
            Else
              Result = AddCryptMemory_(PackEx()\ID, *Output, Size, PackedFileName, Key)
            EndIf
            
            Size + 48
            
            FreeMemory(*Output)
          EndIf
          
        EndIf
        ;}
      Else    ;{ pack file
        
        If PackEx()\Mode = #Open 
          Result = AddMemory2Pack_(*Buffer, Size, PackedFileName, "")
        Else
          Result = AddPackMemory(PackEx()\ID, *Buffer, Size, PackedFileName)
        EndIf
        ;}
      EndIf
      
      If Result
        PackEx()\Files(PackedFileName)\Size = Size
        PackEx()\Files(PackedFileName)\Type = #PB_Packer_File
        PackEx()\Files(PackedFileName)\Flags | #Add | #Memory
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.i DecompressMemory(Pack.i, *Buffer, Size.i, PackedFileName.s, Key.s="")
    Define.i MemSize, Result = -1
    Define.q Counter, qAES_ID
    Define   *Input, *Buffer
    
    If FindMapElement(PackEx(), Str(Pack))
      
      If Key  ;{ decrypt & pack file

        If FindMapElement(PackEx()\Files(), PackedFileName)
          
          MemSize = PackEx()\Files()\Size
          
          *Input = AllocateMemory(MemSize)
          If *Input
            
            If UncompressPackMemory(PackEx()\ID, *Input, MemSize, PackedFileName) <> -1

          	  Counter   = PeekQ(*Input + Size - 8)
              qAES_ID   = PeekQ(*Input + Size - 16)
              qAES\Hash = DecodeHash_(Counter, *Input + Size - 48, #False)
              
              SmartCoder(#Binary, @qAES_ID, @qAES_ID, 8, Str(Counter))
              
              If qAES_ID = #qAES
                
                Size - 48
                
                SmartCoder(#Binary, *Input, *Buffer, Size, Key, Counter)
                
                If qAES\Hash <> Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
                  Error = #ERROR_INTEGRITY_CORRUPTED
                  qAES\Hash  = Fingerprint(*Buffer, Size, #PB_Cipher_SHA3)
                  FreeMemory(*Input)
                  ProcedureReturn #False
                EndIf
                
                Result = Size
                
              Else
                Error = #ERROR_NOT_ENCRYPTED
              EndIf 

            Else
              Error = #ERROR_CANT_UNCOMPRESS_PACKMEMORY
            EndIf
            
            FreeMemory(*Input)  
          EndIf
          
        EndIf
        ;}
      Else    ;{ pack file
        Result = UncompressPackMemory(PackEx()\ID, *Buffer, Size, PackedFileName)
        ;}
      EndIf
      
      If Result
        PackEx()\Files(PackedFileName)\Flags | #Open | #Memory
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure.i AddXML(Pack.i, XML.i, PackedFileName.s, Key.s="")
    Define   *Buffer
    Define.q Counter, Hash, qAES_ID = #qAES
    Define.i Size, Result
        
    If FindMapElement(PackEx(), Str(Pack))
      
      If IsXML(XML)
        
        Size = ExportXMLSize(XML)
        If Size
          
          *Buffer = AllocateMemory(Size + 48)
          If *Buffer
            
            If ExportXML(XML, *Buffer, Size)
              
              If PackEx()\Mode = #Open
                
                Result = AddMemory2Pack_(*Buffer, Size, PackedFileName, Key)
                If Result And Key : Size + 48 : EndIf
                
              Else
                
                If Key
                  Result = AddCryptMemory_(PackEx()\ID, *Buffer, Size, PackedFileName, Key)
                  If Result : Size + 48 : EndIf
                Else
                  Result = AddPackMemory(PackEx()\ID, *Buffer, Size, PackedFileName)
                EndIf
              
              EndIf
              
            EndIf
            
            FreeMemory(*Buffer)
          EndIf  

        EndIf
        
        If Result
          PackEx()\Files(PackedFileName)\Size = Size
          PackEx()\Files(PackedFileName)\Type = #PB_Packer_File
          PackEx()\Files(PackedFileName)\ID   = XML
          PackEx()\Files(PackedFileName)\Flags | #Add | #XML
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.i DecompressXML(Pack.i, XML.i, PackedFileName.s, Key.s="", Flags.i=#False, Encoding.i=#PB_UTF8)
    Define   *Buffer
    Define.q Counter, Hash, qAES_ID
    Define.i Size, Result 
    
    If FindMapElement(PackEx(), Str(Pack))
      
      If FindMapElement(PackEx()\Files(), PackedFileName)
       
        Size = PackEx()\Files()\Size
    
        *Buffer = AllocateMemory(Size)
        If *Buffer
          
          If UncompressPackMemory(PackEx()\ID, *Buffer, Size, PackedFileName) <> -1
            
            If DecryptMemory_(*Buffer, Size, Key)

              Result = CatchXML(XML, *Buffer, Size - 48, Flags, Encoding)
              
            EndIf
          
          Else
            Error = #ERROR_CANT_UNCOMPRESS_PACKMEMORY
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
       
      EndIf
      
      If Result
        PackEx()\Files(PackedFileName)\ID = XML
        PackEx()\Files(PackedFileName)\Flags | #Open | #XML
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure.i AddJSON(Pack.i, JSON.i, PackedFileName.s, Key.s="")
    Define   *Buffer
    Define.q Counter, Hash, qAES_ID = #qAES
    Define.i Size, Result
    
    If FindMapElement(PackEx(), Str(Pack))
      
      If IsJSON(JSON)
        
        Size = ExportJSONSize(JSON)
        If Size
          
          *Buffer = AllocateMemory(Size + 48)
          If *Buffer
            
            If ExportJSON(JSON, *Buffer, Size)
              
              If PackEx()\Mode = #Open
                
                Result = AddMemory2Pack_(*Buffer, Size, PackedFileName, Key)
                If Result And Key : Size + 48 : EndIf
                
              Else
                
                If Key
                  Result = AddCryptMemory_(PackEx()\ID, *Buffer, Size, PackedFileName, Key)
                  If Result : Size + 48 : EndIf
                Else
                  Result = AddPackMemory(PackEx()\ID, *Buffer, Size, PackedFileName)
                EndIf
              
              EndIf
              
            EndIf
            
            FreeMemory(*Buffer)
          EndIf  

        EndIf
        
        If Result
          PackEx()\Files(PackedFileName)\Size = Size
          PackEx()\Files(PackedFileName)\Type = #PB_Packer_File
          PackEx()\Files(PackedFileName)\ID   = JSON
          PackEx()\Files(PackedFileName)\Flags | #Add | #JSON
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.i DecompressJSON(Pack.i, JSON.i, PackedFileName.s, Key.s="", Flags.i=#False)
    Define   *Buffer
    Define.q Counter, Hash, qAES_ID
    Define.i Size, Result
    
    If FindMapElement(PackEx(), Str(Pack))
      
      If FindMapElement(PackEx()\Files(), PackedFileName)
       
        Size = PackEx()\Files()\Size
    
        *Buffer = AllocateMemory(Size)
        If *Buffer
          
          If UncompressPackMemory(PackEx()\ID, *Buffer, Size, PackedFileName) <> -1
            
            If DecryptMemory_(*Buffer, Size, Key)

              Result = CatchJSON(JSON, *Buffer, Size - 48, Flags)
            
            EndIf
            
          Else
            Error = #ERROR_CANT_UNCOMPRESS_PACKMEMORY  
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
      EndIf
      
      If Result
        PackEx()\Files(PackedFileName)\ID = JSON
        PackEx()\Files(PackedFileName)\Flags | #Open | #JSON
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure.i AddImage(Pack.i, Image.i, PackedFileName.s, Key.s="")
    Define   *Buffer
    Define.q Counter, Hash, qAES_ID = #qAES
    Define.i Size, Result
    
    If FindMapElement(PackEx(), Str(Pack))
      
      If IsImage(Image)

        *Buffer = EncodeImage(Image)
        If *Buffer
          
          Size = MemorySize(*Buffer)

          If Key  ;{ encrypt & pack file
            
            *Buffer = ReAllocateMemory(*Buffer, Size + 48)
            If *Buffer

              If PackEx()\Mode = #Open
                Result = AddMemory2Pack_(*Buffer, Size, PackedFileName, Key)
              Else
                Result = AddCryptMemory_(PackEx()\ID, *Buffer, Size, PackedFileName, Key)
              EndIf
              
              Size + 48
              
            EndIf  
            ;}
          Else    ;{ pack file
            
            If PackEx()\Mode = #Open 
              Result = AddMemory2Pack_(*Buffer, Size, PackedFileName, "")
            Else
              Result = AddPackMemory(PackEx()\ID, *Buffer, Size, PackedFileName)
            EndIf
            ;}
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
        
        If Result
          PackEx()\Files(PackedFileName)\Size = Size
          PackEx()\Files(PackedFileName)\Type = #PB_Packer_File
          PackEx()\Files(PackedFileName)\ID   = Image
          PackEx()\Files(PackedFileName)\Flags | #Add | #IMAGE
        EndIf
        
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.i DecompressImage(Pack.i, Image.i, PackedFileName.s, Key.s="")
    Define   *Buffer
    Define.q Counter, Hash, qAES_ID
    Define.i Size, Result
    
    If FindMapElement(PackEx(), Str(Pack))
      
      If FindMapElement(PackEx()\Files(), PackedFileName)
        
        Size = PackEx()\Files()\Size
    
        *Buffer = AllocateMemory(Size)
        If *Buffer
          
          If UncompressPackMemory(PackEx()\ID, *Buffer, Size, PackedFileName) <> -1
            
            If DecryptMemory_(*Buffer, Size, Key)

              Result = CatchImage(Image, *Buffer, Size - 48)
              
            EndIf 
          
          Else
            Error = #ERROR_CANT_UNCOMPRESS_PACKMEMORY  
          EndIf
          
          FreeMemory(*Buffer)
        EndIf
       
      EndIf
      
      If Result
        PackEx()\Files(PackedFileName)\ID = Image
        PackEx()\Files(PackedFileName)\Flags | #Open | #Image
      EndIf
      
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  
  Procedure.i DecompressSound(Pack.i, Sound.i, PackedFileName.s, Key.s="")
    Define   *Buffer
    Define.q Counter, Hash, qAES_ID
    Define.i Size, Result
    
    If FindMapElement(PackEx(), Str(Pack))
      
      If FindMapElement(PackEx()\Files(), PackedFileName)
          
          Size = PackEx()\Files()\Size
      
          *Buffer = AllocateMemory(Size)
          If *Buffer
            
            If UncompressPackMemory(PackEx()\ID, *Buffer, Size, PackedFileName) <> -1
              
              If DecryptMemory_(*Buffer, Size, Key)

                Result = CatchSound(Sound, *Buffer, Size - 48)
                
              EndIf
            
            Else
              Error = #ERROR_CANT_UNCOMPRESS_PACKMEMORY  
            EndIf
            
            FreeMemory(*Buffer)
          EndIf
          
      EndIf
     
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  
  Procedure.i DecompressSprite(Pack.i, Sprite.i, PackedFileName.s, Key.s="", Flags.i=#False)
    Define   *Buffer
    Define.q Counter, Hash, qAES_ID
    Define.i Size, Result
    
    If FindMapElement(PackEx(), Str(Pack))
      
      If FindMapElement(PackEx()\Files(), PackedFileName)
          
          Size = PackEx()\Files()\Size
      
          *Buffer = AllocateMemory(Size)
          If *Buffer
            
            If UncompressPackMemory(PackEx()\ID, *Buffer, Size, PackedFileName) <> -1
              
              If DecryptMemory_(*Buffer, Size, Key)
              
                Result = CatchSprite(Sprite, *Buffer, Flags)
                
              EndIf
            
            Else
              Error = #ERROR_CANT_UNCOMPRESS_PACKMEMORY  
            EndIf
            
            FreeMemory(*Buffer)
          EndIf
          
      EndIf
     
    EndIf
    
    ProcedureReturn Result
  EndProcedure

  Procedure.i DecompressMusic(Pack.i, Music.i, PackedFileName.s, Key.s="", Flags.i=#False)
    Define   *Buffer
    Define.q Counter, Hash, qAES_ID
    Define.i Size, Result
    
    If FindMapElement(PackEx(), Str(Pack))
      
      If FindMapElement(PackEx()\Files(), PackedFileName)
          
          Size = PackEx()\Files()\Size
      
          *Buffer = AllocateMemory(Size)
          If *Buffer
            
            If UncompressPackMemory(PackEx()\ID, *Buffer, Size, PackedFileName) <> -1
              
              If DecryptMemory_(*Buffer, Size, Key)
              
                Result = CatchMusic(Music, *Buffer, Size - 48)
                
              EndIf
              
            Else
              Error = #ERROR_CANT_UNCOMPRESS_PACKMEMORY  
            EndIf
            
            FreeMemory(*Buffer)
          EndIf
          
      EndIf
     
    EndIf
    
    ProcedureReturn Result
  EndProcedure
  

  Procedure.i RemoveFile(Pack.i, PackedFileName.s) 
    
    If FindMapElement(PackEx(), Str(Pack))
      
      RemoveFile_(PackedFileName)
      
    EndIf
    
  EndProcedure
  
  Procedure   Close(Pack.i, Flags.i=#False)
    Define.s File
    
    If FindMapElement(PackEx(), Str(Pack))
      
      If Flags & #MoveBack Or Flags & #Update
        
        ForEach PackEx()\Files()
          
          If PackEx()\Files()\Flags & #Open
            
            If Flags & #File And PackEx()\Files()\Flags & #File ;{ MoveBack files
              
              File = PackEx()\Files()\Path + MapKey(PackEx()\Files())
              
              If FileSize(File) > 0
                
                If AddFile(Pack, File, MapKey(PackEx()\Files()), PackEx()\Files()\Key)
                  
                  If Flags & #MoveBack : DeleteFile(File) : EndIf
                  
                EndIf
                
              EndIf
              ;}
            EndIf
            
          EndIf 
          
        Next
        
      EndIf
      
      ClosePack(PackEx()\ID)
      
      DeleteMapElement(PackEx())
    EndIf
    
  EndProcedure
  
  ;- _____ Encryption _____
  
  Procedure   SetSalt(String.s)
	  qAES\Salt = String
	EndProcedure

EndModule

;- ========  Module - Example ========

CompilerIf #PB_Compiler_IsMainFile
  
  #Example = 1
  
  ; 1: normal
  ; 2: encrypted
  ; 3: delete
  ; 4: XML
  ; 5: JSON
  ; 6: Image
  
  UseZipPacker()

  #Pack = 1
  
  Key$  = "18qAES07PW67"
  
  CompilerSelect #Example
    CompilerCase 1 ;{ pack normal file
      
      If PackEx::Create(#Pack, "TestPack.zip")
        PackEx::AddFile(#Pack, "PureBasic.jpg", "PureBasic1.jpg")
        PackEx::Close(#Pack)
      EndIf
      
      If PackEx::Open(#Pack, "TestPack.zip")
        PackEx::DecompressFile(#Pack, "PureBasic1.jpg", "PureBasic1.jpg")
        PackEx::AddFile(#Pack, "PureBasic.jpg", "PureBasic2.jpg")
        
        MessageRequester("PackEx", "Close Pack")
        
        PackEx::Close(#Pack, PackEx::#File|PackEx::#MoveBack) ; close pack & move uncompressed files (PureBasic1.jpg) back to pack
        ;PackEx::Close(#Pack, PackEx::#File|PackEx::#Update) ; close pack & update uncompressed files (PureBasic1.jpg) in pack
      EndIf
      ;}
    CompilerCase 2 ;{ pack encrypted file 
      
      If PackEx::Create(#Pack, "TestCryptPack.zip")
        PackEx::AddFile(#Pack, "PureBasic.jpg", "PureBasic.jpg", Key$)
        PackEx::Close(#Pack)
      EndIf
      
      If PackEx::Open(#Pack, "TestCryptPack.zip")
        If PackEx::IsEncrypted(#Pack, "PureBasic.jpg")
          Debug "Packed file is encrypted"
        Else
          Debug "Packed file is not encrypted"
        EndIf
        PackEx::DecompressFile(#Pack, "Decrypted.jpg", "PureBasic.jpg", Key$)
        PackEx::Close(#Pack)
      EndIf 
      ;}
    CompilerCase 3 ;{ delete packed file
      
      If PackEx::Create(#Pack, "TestPack.zip")
        PackEx::AddFile(#Pack, "PureBasic.jpg", "PureBasic.jpg")
        PackEx::AddFile(#Pack, "Test.txt", "Test.txt")
        PackEx::Close(#Pack)
      EndIf
      
      MessageRequester("PackEx", "Remove 'PureBasic.jpg'")
      
      If PackEx::Open(#Pack, "TestPack.zip")
        PackEx::RemoveFile(#Pack, "PureBasic.jpg")
        PackEx::Close(#Pack)
      EndIf
      ;}
    CompilerCase 4 ;{ pack xml

      #XML  = 1
      
      NewList Shapes$()
      
      AddElement(Shapes$()): Shapes$() = "square"
      AddElement(Shapes$()): Shapes$() = "circle"
      AddElement(Shapes$()): Shapes$() = "triangle"
    
      If CreateXML(#XML)
        InsertXMLList(RootXMLNode(#XML), Shapes$())
        If PackEx::Create(#Pack, "TestXML.zip")
          PackEx::AddXML(#Pack, #XML, "Shapes.xml", Key$)
          PackEx::Close(#Pack)
        EndIf
        FreeXML(#XML)
      EndIf
      
      If PackEx::Open(#Pack, "TestXML.zip")
        If PackEx::DecompressXML(#Pack, #XML, "Shapes.xml", Key$)
          Debug ComposeXML(#XML)
          FreeXML(#XML)
        EndIf
        PackEx::Close(#Pack) 
      EndIf
      ;}
    CompilerCase 5 ;{ pack json
     
      #JSON = 1
      
      If CreateJSON(#JSON)
        Person.i = SetJSONObject(JSONValue(#JSON))
        SetJSONString(AddJSONMember(Person, "FirstName"), "John")
        SetJSONString(AddJSONMember(Person, "LastName"), "Smith")
        SetJSONInteger(AddJSONMember(Person, "Age"), 42)
        If PackEx::Create(#Pack, "TestJSON.zip")
          PackEx::AddJSON(#Pack, #JSON, "Person.json", Key$)
          PackEx::Close(#Pack) 
        EndIf
        FreeJSON(#JSON)
      EndIf
      
      If PackEx::Open(#Pack, "TestJSON.zip")
        If PackEx::DecompressJSON(#Pack, #JSON, "Person.json", Key$)
          Debug ComposeJSON(#JSON, #PB_JSON_PrettyPrint)
          FreeJSON(#JSON)
        EndIf
        PackEx::Close(#Pack) 
      EndIf
      ;}
    CompilerCase 6 ;{ pack image
      
      UseJPEGImageDecoder()
      
      #Image = 1
      
      If LoadImage(#Image, "PureBasic.jpg")
        If PackEx::Create(#Pack, "TestImage.zip")
          PackEx::AddImage(#Pack, #Image, "PureBasic.jpg", Key$)
          PackEx::Close(#Pack) 
        EndIf
      EndIf
      
      If PackEx::Open(#Pack, "TestImage.zip")
        If PackEx::DecompressImage(#Pack, #Image, "PureBasic.jpg", Key$)
          SaveImage(#Image, "DecryptedImage.jpg")
        EndIf
        PackEx::Close(#Pack) 
      EndIf
      
      ;}
  CompilerEndSelect    
  
  
CompilerEndIf  
; IDE Options = PureBasic 5.71 beta 2 LTS (Windows - x64)
; CursorPosition = 1541
; FirstLine = 155
; Folding = KwHAAAQCMgz-
; EnableXP
; DPIAware