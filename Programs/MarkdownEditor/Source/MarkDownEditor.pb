﻿;/ ==================================
;/ =    MarkDownEditor.pbi    =
;/ ==================================
;/
;/ [ PB V5.7x / 64Bit / All OS / DPI ]
;/
;/  Gadget to display MarkDown languages
;/
;/ © 2020  by Thorsten Hoeppner (01/2020)
;/

; Last Update: 08.01.2020

; PDF-Icon: Icon erstellt von Dimitry Miroliubov (https://www.flaticon.com)

XIncludeFile "Module\AppRegistryModule.pbi"
XIncludeFile "Module\ResizeExModule.pbi"
XIncludeFile "Module\ResourceExModule.pbi"
XIncludeFile "Module\pbPDFModule.pbi"
XIncludeFile "Module\MarkDownModule.pbi"
XIncludeFile "Module\EditorExModule.pbi"

EnableExplicit

UsePNGImageDecoder()
UseLZMAPacker()

;- __________ Constants __________

#AppReg = 1
#ResEx  = 1
#File   = 1
#XML    = 1
#Dir    = 1

;{ Menu Constants
Enumeration 1
  #PopupMenu
EndEnumeration  
;}

;{ Window Constants
Enumeration 1
  #Window_MarkDown
  #Window_Settings
  #Window_Table
EndEnumeration
;}

;{ Gadget Constants
Enumeration 1
  
  ;{ Menue items
  #Menu_Copy
  #Menu_Cut
  #Menu_Paste
  #Menu_H1
  #Menu_H2
  #Menu_H3
  #Menu_H4
  #Menu_H5
  #Menu_H6
  #Menu_Bold
  #Menu_Italic
  #Menu_BoldItalic
  #Menu_Strikethrough
  #Menu_Highlight
  #Menu_Code
  #Menu_SubScript
  #Menu_SuperScript
  #Menu_Keystroke
  #Menu_Footnote
  #Menu_URL
  #Menu_Link
  #Menu_LinkRef
  #Menu_Image
  #Menu_ImageRef
  #Menu_Abbreviation
  #Menu_Ref_Footnote
  #Menu_Ref_Link
  #Menu_Ref_Image  
  #Emoji_Bookmark
  #Emoji_Date
  #Emoji_Mail
  #Emoji_Memo
  #Emoji_Pencil
  #Emoji_Phone
  #Emoji_Bulb
  #Emoji_Clip
  #Emoji_Magnifier
  #Emoji_Warning
  ;}
  
  ;{ #Window_MarkDown  
  #Gadget_MarkDown_Editor
  #Gadget_MarkDown_Bt_Update
  #Gadget_MarkDown_Bt_Table
  #Gadget_MarkDown_Bt_Settings
  #Gadget_MarkDown_Viewer
  #Gadget_MarkDown_Bt_New
  #Gadget_MarkDown_Bt_Open
  #Gadget_MarkDown_Bt_Save
  #Gadget_MarkDown_Bt_PDF
  #Gadget_MarkDown_Bt_HTML
  ;}
  
  ;{ #Window_Settings
  #Gadget_Settings_Frame
  #Gadget_Settings_Tx_Language
  #Gadget_Settings_CB_Code
  #Gadget_Settings_OG_SpellCheck
  #Gadget_Settings_CB_Dictionary
  #Gadget_Settings_Bt_Apply
  ;}
  
  ;{ #Window_Table
  #Gadget_Table_Frame
  #Gadget_Table_Tx_Rows
  #Gadget_Table_SpG_Rows
  #Gadget_Table_Tx_Columns
  #Gadget_Table_SpG_Columns
  #Gadget_Table_Tx_Align
  #Gadget_Table_SpG_Align
  #Gadget_Table_CB_Align
  #Gadget_Table_OK
  ;}
  
EndEnumeration
;}

;- __________ Fonts __________

;{ Font Constants
Enumeration 1
  #Font_Arial9
  #Font_Arial9B
  #Font_Arial11
EndEnumeration  
;}

LoadFont(#Font_Arial9,   "Arial",  9)
LoadFont(#Font_Arial9B,  "Arial",  9, #PB_Font_Bold)
LoadFont(#Font_Arial11,  "Arial", 11)

;- __________ Images __________

;{ Image Constants
Enumeration 1
  #IMG_Copy
  #IMG_Cut
  #IMG_Paste
  #IMG_New
  #IMG_Open
  #IMG_Save
  #IMG_Update
  #IMG_Table
  #IMG_Settings
  #IMG_PDF
  #IMG_HTML
  #IMG_Bookmark
  #IMG_Date
  #IMG_Mail
  #IMG_Memo
  #IMG_Pencil
  #IMG_Phone
  #IMG_Bold
  #IMG_Italic
  #IMG_BoldItalic
  #IMG_Strikethrough
  #IMG_Subscript
  #IMG_Superscript
  #IMG_LinkAdd
  #IMG_Link
  #IMG_LinkInline
  #IMG_Highlight
  #IMG_Image
  #IMG_ImageInline
  #IMG_ImageLink
  #IMG_Autolink
  #IMG_Keystroke
  #IMG_Footnote
  #IMG_H1
  #IMG_Code
  #IMG_Warning
  #IMG_Bulb
  #IMG_Clip
  #IMG_Magnifier
EndEnumeration
;}

;{ Load Images
If ResourceEx::Open(#ResEx, "MarkDownEditor.res")
  ResourceEx::UseImage(#ResEx, #IMG_Copy,          "Copy.png")
  ResourceEx::UseImage(#ResEx, #IMG_Cut,           "Cut.png")
  ResourceEx::UseImage(#ResEx, #IMG_Paste,         "Paste.png")
  ResourceEx::UseImage(#ResEx, #IMG_New,           "New.png")
  ResourceEx::UseImage(#ResEx, #IMG_Open,          "Open.png")
  ResourceEx::UseImage(#ResEx, #IMG_Save,          "Save.png")
  ResourceEx::UseImage(#ResEx, #IMG_Update,        "Update.png")
  ResourceEx::UseImage(#ResEx, #IMG_Table,         "Table.png")
  ResourceEx::UseImage(#ResEx, #IMG_Settings,      "Settings.png")
  ResourceEx::UseImage(#ResEx, #IMG_PDF,           "PDF.png")
  ResourceEx::UseImage(#ResEx, #IMG_HTML,          "HTML.png")
  ResourceEx::UseImage(#ResEx, #IMG_Bookmark,      "BookMark.png")
  ResourceEx::UseImage(#ResEx, #IMG_Date,          "Date.png")
  ResourceEx::UseImage(#ResEx, #IMG_Mail,          "Mail.png")
  ResourceEx::UseImage(#ResEx, #IMG_Memo,          "Memo.png")
  ResourceEx::UseImage(#ResEx, #IMG_Pencil,        "Pencil.png")
  ResourceEx::UseImage(#ResEx, #IMG_Phone,         "Phone.png")
  ResourceEx::UseImage(#ResEx, #IMG_Bold,          "Bold.png")
  ResourceEx::UseImage(#ResEx, #IMG_Italic,        "Italic.png")
  ResourceEx::UseImage(#ResEx, #IMG_BoldItalic,    "BoldItalic.png")
  ResourceEx::UseImage(#ResEx, #IMG_Strikethrough, "Strikethrough.png")
  ResourceEx::UseImage(#ResEx, #IMG_Subscript,     "Subscript.png")
  ResourceEx::UseImage(#ResEx, #IMG_Superscript,   "Superscript.png")
  ResourceEx::UseImage(#ResEx, #IMG_LinkAdd,       "LinkAdd.png")
  ResourceEx::UseImage(#ResEx, #IMG_Link,          "Link.png")
  ResourceEx::UseImage(#ResEx, #IMG_LinkInline,    "LinkInline.png")
  ResourceEx::UseImage(#ResEx, #IMG_Image,         "Image.png")
  ResourceEx::UseImage(#ResEx, #IMG_ImageInline,   "ImageInline.png")
  ResourceEx::UseImage(#ResEx, #IMG_ImageLink,     "ImageLink.png")
  ResourceEx::UseImage(#ResEx, #IMG_Autolink,      "AutoLink.png")
  ResourceEx::UseImage(#ResEx, #IMG_Highlight,     "Highlight.png")
  ResourceEx::UseImage(#ResEx, #IMG_Keystroke,     "KeyStroke.png")
  ResourceEx::UseImage(#ResEx, #IMG_Footnote,      "FootNote.png")
  ResourceEx::UseImage(#ResEx, #IMG_H1,            "H1.png")
  ResourceEx::UseImage(#ResEx, #IMG_Code,          "Code.png")
  ResourceEx::UseImage(#ResEx, #IMG_Warning,       "Warning.png")
  ResourceEx::UseImage(#ResEx, #IMG_Bulb,          "Bulb.png")
  ResourceEx::UseImage(#ResEx, #IMG_Clip,          "Clip.png")
  ResourceEx::UseImage(#ResEx, #IMG_Magnifier,     "Magnifier.png")
EndIf ;}

;- __________ Structures __________

Structure Language_Structure 
  Map Strg.s()
EndStructure
Global NewMap Language.Language_Structure()

Global NewMap Lng.s()

;- __________ Windows __________

Procedure.i Window_Table()
  
  If OpenWindow(#Window_Table, 0, 0, 170, 152, " " + Lng("Table"), #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_WindowCentered|#PB_Window_Invisible, WindowID(#Window_MarkDown))
    
    FrameGadget(#Gadget_Table_Frame, 10, 5, 150, 107, "")
    
    TextGadget(#Gadget_Table_Tx_Rows, 20, 20, 50, 15, Lng("Rows")+":")
      SetGadgetFont(#Gadget_Table_Tx_Rows, FontID(#Font_Arial9B))
    SpinGadget(#Gadget_Table_SpG_Rows, 20, 36, 45, 20, 1, 20, #PB_Spin_Numeric)
    
    TextGadget(#Gadget_Table_Tx_Columns, 80, 20, 70, 15, Lng("Columns")+":")
      SetGadgetFont(#Gadget_Table_Tx_Columns, FontID(#Font_Arial9B))
    SpinGadget(#Gadget_Table_SpG_Columns, 80, 36, 45, 20, 1, 10, #PB_Spin_Numeric)
    
    TextGadget(#Gadget_Table_Tx_Align, 20, 66, 130, 15, Lng("ColAlign")+":")
      SetGadgetFont(#Gadget_Table_Tx_Align, FontID(#Font_Arial9B))
    SpinGadget(#Gadget_Table_SpG_Align, 20, 82, 45, 20, 1, 2, #PB_Spin_ReadOnly|#PB_Spin_Numeric)
    ComboBoxGadget(#Gadget_Table_CB_Align, 70, 82, 80, 20)
    
    ButtonGadget(#Gadget_Table_OK, 45, 117, 80, 25, Lng("Apply"))
   
    HideWindow(#Window_Table, #False)
   
    ProcedureReturn WindowID(#Window_Table)
  EndIf
  
EndProcedure

Procedure.i Window_Settings()
  Define.i gWidth
  
  If OpenWindow(#Window_Settings, 0, 0, 180, 157, " " + Lng("Settings"), #PB_Window_SystemMenu|#PB_Window_Tool|#PB_Window_WindowCentered|#PB_Window_Invisible, WindowID(#Window_MarkDown))
    
    FrameGadget(#Gadget_Settings_Frame, 10, 5, 160, 112, "")
    
    TextGadget(#Gadget_Settings_Tx_Language, 25, 28, 55, 18, Lng("Language") + ": ")
      SetGadgetFont(#Gadget_Settings_Tx_Language, FontID(#Font_Arial9))
      gWidth = GadgetWidth(#Gadget_Settings_Tx_Language, #PB_Gadget_RequiredSize)
      ResizeGadget(#Gadget_Settings_Tx_Language, #PB_Ignore, #PB_Ignore, gWidth, #PB_Ignore)
    ComboBoxGadget(#Gadget_Settings_CB_Code, gWidth + 25, 25, 40, 22)
      SetGadgetFont(#Gadget_Settings_CB_Code, FontID(#Font_Arial9B))
    CheckBoxGadget(#Gadget_Settings_OG_SpellCheck, 25, 57, 125, 15, " " + Lng("Spellcheck"))
      SetGadgetFont(#Gadget_Settings_OG_SpellCheck, FontID(#Font_Arial9))
    ComboBoxGadget(#Gadget_Settings_CB_Dictionary, 25, 80, 130, 22)
      SetGadgetFont(#Gadget_Settings_CB_Dictionary, FontID(#Font_Arial9B))
    
    ButtonGadget(#Gadget_Settings_Bt_Apply, 50, 122, 80, 25, Lng("Apply"))
    
    DisableGadget(#Gadget_Settings_CB_Dictionary, #True)
    
    HideWindow(#Window_Settings, #False)
    
    ProcedureReturn WindowID(#Window_Settings)
  EndIf
EndProcedure

Procedure.i Window_MarkDown()
  
  If OpenWindow(#Window_MarkDown, 0, 0, 800, 600, " MarkDown - Editor", #PB_Window_SystemMenu|#PB_Window_MinimizeGadget|#PB_Window_MaximizeGadget|#PB_Window_SizeGadget|#PB_Window_ScreenCentered|#PB_Window_Invisible)
    
    If CreatePopupImageMenu(#PopupMenu) ;{ PopupMenu
      MenuItem(#Menu_Copy,  Lng("Copy"),  ImageID(#IMG_Copy))
      MenuItem(#Menu_Cut,   Lng("Cut"),   ImageID(#IMG_Cut))
      MenuItem(#Menu_Paste, Lng("Paste"), ImageID(#IMG_Paste))
      MenuBar()
      OpenSubMenu(Lng("Headings"), ImageID(#IMG_H1))
        MenuItem(#Menu_H1, "H1")
        MenuItem(#Menu_H2, "H2")
        MenuItem(#Menu_H3, "H3")
        MenuItem(#Menu_H4, "H4")
        MenuItem(#Menu_H5, "H5")
        MenuItem(#Menu_H6, "H6")
      CloseSubMenu()
      MenuBar()
      MenuItem(#Menu_Code, Lng("Code"),                     ImageID(#IMG_Code))  
      OpenSubMenu(Lng("Emphasis"), ImageID(#IMG_BoldItalic))
        MenuItem(#Menu_Bold,         Lng("Bold"),           ImageID(#IMG_Bold))
        MenuItem(#Menu_Italic,       Lng("Italic"),         ImageID(#IMG_Italic))
        MenuItem(#Menu_BoldItalic,   Lng("Bold")+"/"+Lng("Italic"), ImageID(#IMG_BoldItalic))
        MenuBar()
        MenuItem(#Menu_Highlight,    Lng("Highlight"),      ImageID(#IMG_Highlight))
      CloseSubMenu() 
      MenuItem(#Menu_Strikethrough,  Lng("Strikethrough"),  ImageID(#IMG_Strikethrough))
      MenuBar()
      MenuItem(#Menu_SubScript,      Lng("SubScript"),      ImageID(#IMG_Subscript))
      MenuItem(#Menu_SuperScript,    Lng("SuperScript"),    ImageID(#IMG_Superscript))
      MenuBar()
      MenuItem(#Menu_Keystroke,      Lng("Keystroke"),      ImageID(#IMG_Keystroke))
      MenuBar()
      MenuItem(#Menu_Footnote,       Lng("Footnote"),       ImageID(#IMG_Footnote))
      MenuItem(#Menu_URL,            "URL/" + Lng("EMail"), ImageID(#IMG_Autolink))
      OpenSubMenu(Lng("Link"), ImageID(#IMG_LinkAdd))
        MenuItem(#Menu_Link,         Lng("Inline"),         ImageID(#IMG_LinkInline))
        MenuItem(#Menu_LinkRef,      Lng("Reference"),      ImageID(#IMG_Link))
      CloseSubMenu()
      OpenSubMenu(Lng("Image"), ImageID(#IMG_Image))
        MenuItem(#Menu_Image,        Lng("Inline"),         ImageID(#IMG_ImageInline))
        MenuItem(#Menu_ImageRef,     Lng("Reference"),      ImageID(#IMG_ImageLink))
      CloseSubMenu()
      MenuBar()
      MenuItem(#Menu_Abbreviation,   Lng("Abbreviation"))
      OpenSubMenu(Lng("Reference"))
        MenuItem(#Menu_Ref_Footnote, Lng("Footnote"),       ImageID(#IMG_Footnote))
        MenuItem(#Menu_Ref_Link,     Lng("Link"),           ImageID(#IMG_Link))
        MenuItem(#Menu_Ref_Image,    Lng("Image"),          ImageID(#IMG_Image))
      CloseSubMenu()
      MenuBar()
      OpenSubMenu(Lng("Emoji"))
        MenuItem(#Emoji_Bookmark,    Lng("Bookmark"),       ImageID(#IMG_Bookmark))
        MenuItem(#Emoji_Bulb,        Lng("Bulb"),           ImageID(#IMG_Bulb))
        MenuItem(#Emoji_Clip,        Lng("Paperclip"),      ImageID(#IMG_Clip))
        MenuItem(#Emoji_Date,        Lng("Date"),           ImageID(#IMG_Date))
        MenuItem(#Emoji_Magnifier,   Lng("Magnifier"),      ImageID(#IMG_Magnifier))
        MenuItem(#Emoji_Mail,        Lng("Mail"),           ImageID(#IMG_Mail))
        MenuItem(#Emoji_Memo,        Lng("Memo"),           ImageID(#IMG_Memo))
        MenuItem(#Emoji_Pencil,      Lng("Pencil"),         ImageID(#IMG_Pencil))
        MenuItem(#Emoji_Phone,       Lng("Phone"),          ImageID(#IMG_Phone))
        MenuItem(#Emoji_Warning,     Lng("Warning"),        ImageID(#IMG_Warning))
      CloseSubMenu()
    EndIf ;}
    
    If EditEx::Gadget(#Gadget_MarkDown_Editor, 10, 10, 385, 545, EditEx::#WordWrap, #Window_MarkDown)
      EditEx::DisableSuggestions(#Gadget_MarkDown_Editor, #True)
      EditEx::SetColor(#Gadget_MarkDown_Editor, EditEx::#BackColor, $FBFFFF)
      EditEx::SetFont(#Gadget_MarkDown_Editor, FontID(#Font_Arial11))
    EndIf 
    
    If MarkDown::Gadget(#Gadget_MarkDown_Viewer, 405, 10, 385, 545)
      MarkDown::SetFont(#Gadget_MarkDown_Viewer, "Arial", 11)
      MarkDown::SetMargins(#Gadget_MarkDown_Viewer, 10, 10)
    EndIf

    ButtonImageGadget(#Gadget_MarkDown_Bt_Update,    10, 560, 30, 30, ImageID(#IMG_Update))
    ButtonImageGadget(#Gadget_MarkDown_Bt_Table,     55, 560, 30, 30, ImageID(#IMG_Table))
    
    ButtonImageGadget(#Gadget_MarkDown_Bt_New,      405, 560, 30, 30, ImageID(#IMG_New))
    ButtonImageGadget(#Gadget_MarkDown_Bt_Open,     440, 560, 30, 30, ImageID(#IMG_Open))
    ButtonImageGadget(#Gadget_MarkDown_Bt_Save,     475, 560, 30, 30, ImageID(#IMG_Save))
    ButtonImageGadget(#Gadget_MarkDown_Bt_Settings, 515, 560, 30, 30, ImageID(#IMG_Settings))
    ButtonImageGadget(#Gadget_MarkDown_Bt_PDF,      725, 560, 30, 30, ImageID(#IMG_PDF))
    ButtonImageGadget(#Gadget_MarkDown_Bt_HTML,     760, 560, 30, 30, ImageID(#IMG_HTML))
    
    If Resize::AddWindow(#Window_MarkDown, 400, 300)
      Resize::AddGadget(#Gadget_MarkDown_Editor,      Resize::#Width|Resize::#Height)
      Resize::SetFactor(#Gadget_MarkDown_Editor,      Resize::#HFactor, "50%")
      Resize::AddGadget(#Gadget_MarkDown_Viewer,      Resize::#Width|Resize::#Height|Resize::#MoveX)
      Resize::SetFactor(#Gadget_MarkDown_Viewer,      Resize::#HFactor, "50%")
      Resize::AddGadget(#Gadget_MarkDown_Bt_Update,   Resize::#MoveY)
      Resize::AddGadget(#Gadget_MarkDown_Bt_Table,    Resize::#MoveY)
      Resize::AddGadget(#Gadget_MarkDown_Bt_Settings, Resize::#MoveX|Resize::#MoveY)
      Resize::SetFactor(#Gadget_MarkDown_Bt_Settings, Resize::#HFactor, "50%")
      
      Resize::AddGadget(#Gadget_MarkDown_Bt_New,      Resize::#MoveX|Resize::#MoveY)
      Resize::SetFactor(#Gadget_MarkDown_Bt_New,      Resize::#HFactor, "50%")
      Resize::AddGadget(#Gadget_MarkDown_Bt_Open,     Resize::#MoveX|Resize::#MoveY)
      Resize::SetFactor(#Gadget_MarkDown_Bt_Open,     Resize::#HFactor, "50%")
      Resize::AddGadget(#Gadget_MarkDown_Bt_Save,     Resize::#MoveX|Resize::#MoveY)
      Resize::SetFactor(#Gadget_MarkDown_Bt_Save,     Resize::#HFactor, "50%")
      Resize::AddGadget(#Gadget_MarkDown_Bt_PDF,      Resize::#MoveX|Resize::#MoveY)
    EndIf
    
    HideWindow(#Window_MarkDown, #False)
    
    ProcedureReturn WindowID(#Window_MarkDown)
  EndIf
  
EndProcedure

;- __________ Procedures __________

Procedure.s Load_()
  Define.i BOM
  Define.s Text$, File$, Last$
  
  Last$ = AppReg::GetValue(#AppReg, "Last", "Path", "C:\") 
  
  File$ = OpenFileRequester(Lng("Msg_Load"), Last$, "Markdown (*.md)|*.md;*.txt", 0)
  If File$
    
    AppReg::SetValue(#AppReg, "Last", "Path", GetPathPart(File$))
    
    If ReadFile(#File, File$)
      BOM = ReadStringFormat(#File)
      While Eof(#File) = #False
        Text$ + ReadString(#File, BOM) + #LF$
      Wend
      CloseFile(#File)
    EndIf
    
    If Text$
      EditEx::SetText(#Gadget_MarkDown_Editor, Text$)
      MarkDown::SetText(#Gadget_MarkDown_Viewer, Text$)
    EndIf  
    
  EndIf
  
  ProcedureReturn File$
EndProcedure

Procedure.s Save_(FileName.s, SaveAs.i=#True)
  Define.s Text$, File$, Last$
  
  Text$ = EditEx::GetText(#Gadget_MarkDown_Editor)
  
  If Text$ = "" : ProcedureReturn FileName : EndIf 
  
  MarkDown::SetText(#Gadget_MarkDown_Viewer, Text$)
  
  Last$ = AppReg::GetValue(#AppReg, "Last", "Path", "C:\")
  
  If SaveAs
    
    File$ = SaveFileRequester(Lng("Msg_Save"), Last$ + FileName, "Markdown (*.md)|*.md;*.txt", 0)
    If File$
      
      AppReg::SetValue(#AppReg, "Last", "Path", GetPathPart(File$))
      
      If CreateFile(#File, File$, #PB_UTF8)
        WriteStringFormat(#File, #PB_UTF8)
        WriteString(#File, Text$, #PB_UTF8)
        CloseFile(#File)
      EndIf
      
      ProcedureReturn GetFilePart(File$)
    EndIf
    
  Else
    
    If CreateFile(#File, Last$ + FileName, #PB_UTF8)
      WriteStringFormat(#File, #PB_UTF8)
      WriteString(#File, Text$, #PB_UTF8)
      CloseFile(#File)
    EndIf
    
    ProcedureReturn FileName
  EndIf
  
EndProcedure  

Procedure   New_(FileName.s)
  
  If FileName
    If MessageRequester(Lng("TMsg_Close"), Lng("Msg_Close"), #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
      Save_(FileName, #False)
    EndIf
  EndIf
  MarkDown::Clear(#Gadget_MarkDown_Viewer)
  EditEx::SetText(#Gadget_MarkDown_Editor, "")

EndProcedure

Procedure   PopupMenu_(sStrg.s, eStrg.s)
  Define.s String$
  
  If EditEx::IsSelected(#Gadget_MarkDown_Editor)
    String$ = sStrg + EditEx::GetSelection(#Gadget_MarkDown_Editor, #False) + eStrg
  Else
    String$ = sStrg + " " + eStrg
  EndIf
  
  EditEx::InsertText(#Gadget_MarkDown_Editor, String$)
  
EndProcedure

;- __________ Window - Procedures __________

Procedure.s TableWindow()
  Define.i r, c, Col, Cols, Rows
  Define.s Table$
  Define.i quitWindow = #False
  
  NewMap Column.i()
  
  If Window_Table()
    
    SetGadgetText(#Gadget_Table_SpG_Rows, "1")
    SetGadgetText(#Gadget_Table_SpG_Columns, "2")
    SetGadgetText(#Gadget_Table_SpG_Align, "1")
    SetGadgetAttribute(#Gadget_Table_SpG_Align, #PB_Spin_Maximum, 2)

    ;{ Align
    AddGadgetItem(#Gadget_Table_CB_Align, -1, Lng("Left"))
    AddGadgetItem(#Gadget_Table_CB_Align, -1, Lng("Center"))
    AddGadgetItem(#Gadget_Table_CB_Align, -1, Lng("Right"))
    SetGadgetState(#Gadget_Table_CB_Align, 0)
    ;}
    
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow ;{ Close Window
          Select EventWindow()
            Case #Window_Table
              quitWindow = #True
          EndSelect ;}
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Gadget_Table_SpG_Columns ;{ Column number
              SetGadgetAttribute(#Gadget_Table_SpG_Align, #PB_Spin_Maximum, GetGadgetState(#Gadget_Table_SpG_Columns))
              SetGadgetState(#Gadget_Table_SpG_Align, 1)
              ;}
            Case #Gadget_Table_SpG_Align   ;{ Column align 
              Col = GetGadgetState(#Gadget_Table_SpG_Align)
              SetGadgetState(#Gadget_Table_CB_Align, Column(Str(Col)))
              ;}
            Case #Gadget_Table_CB_Align    ;{ Change align
              Col = GetGadgetState(#Gadget_Table_SpG_Align)
              If Column(Str(Col)) <> GetGadgetState(#Gadget_Table_CB_Align)
                Column(Str(Col)) = GetGadgetState(#Gadget_Table_CB_Align)
              EndIf ;}
            Case #Gadget_Table_OK          ;{ Insert Table
              
              Rows = GetGadgetState(#Gadget_Table_SpG_Rows)
              Cols = GetGadgetState(#Gadget_Table_SpG_Columns)

              For r=0 To Rows
                
                Table$ + "|"
                
                For c=1 To Cols : Table$ + Space(8) + "|" : Next
                
                Table$  + #LF$
                
                If r=0 ;{ Header
                  
                  Table$ + "|"
                  
                  For c=1 To Cols  
                    Select Column(Str(c))
                      Case 1
                        Table$ + " :---: |"
                      Case 2
                        Table$ + " ----: |"
                      Default
                        Table$ + " ----- |"
                    EndSelect
                  Next
                  
                  Table$  + #LF$
                   ;}
                EndIf
                
              Next
              
              quitWindow = #True
              ;}
          EndSelect
      EndSelect
    Until quitWindow
    
    CloseWindow(#Window_Table)
  EndIf
  
  ProcedureReturn Table$
EndProcedure

Procedure SettingsWindow()
  Define.i quitWindow = #False
  Define.s Code$
  
  If Window_Settings()
    
    ;{ Language
    ForEach Language()
      AddGadgetItem(#Gadget_Settings_CB_Code, -1, MapKey(Language()))
    Next
    SetGadgetText(#Gadget_Settings_CB_Code, AppReg::GetValue(#AppReg, "Settings", "Language", "GB") )
    ;}
    
    ;{ Dictionary
    If ExamineDirectory(#Dir, GetCurrentDirectory(), "*.dic")  
      
      While NextDirectoryEntry(#Dir)
        If DirectoryEntryType(#Dir) = #PB_DirectoryEntry_File
          AddGadgetItem(#Gadget_Settings_CB_Dictionary, -1, GetFilePart(DirectoryEntryName(#Dir)))
        EndIf
      Wend
      
      FinishDirectory(#Dir)
    EndIf
    
    SetGadgetText(#Gadget_Settings_CB_Dictionary, AppReg::GetValue(#AppReg, "Settings", "Dictionary"))
    
    SetGadgetState(#Gadget_Settings_OG_SpellCheck, AppReg::SetInteger(#AppReg, "Settings", "SpellCheck", #False))
    If AppReg::SetInteger(#AppReg, "Settings", "SpellCheck", #False)
      SetGadgetState(#Gadget_Settings_OG_SpellCheck, #True)
      DisableGadget(#Gadget_Settings_CB_Dictionary, #False)
    EndIf 
    ;}
    
    Repeat
      Select WaitWindowEvent()
        Case #PB_Event_CloseWindow               ;{ Close Window
          Select EventWindow()
            Case #Window_Settings
              quitWindow = #True
          EndSelect ;}
        Case #PB_Event_Gadget
          Select EventGadget()
            Case #Gadget_Settings_OG_SpellCheck  ;{ SpellCheck
              
              If GetGadgetState(#Gadget_Settings_OG_SpellCheck)
                DisableGadget(#Gadget_Settings_CB_Dictionary, #False)
              Else
                DisableGadget(#Gadget_Settings_CB_Dictionary, #True)
              EndIf
              ;}
            Case #Gadget_Settings_Bt_Apply       ;{ Apply Settings
              
              ;{ Language
              Code$ = GetGadgetText(#Gadget_Settings_CB_Code)
              If FindMapElement(Language(), Code$)
                AppReg::SetValue(#AppReg, "Settings", "Language", Code$)
                CopyMap(Language()\Strg(), Lng())
              EndIf ;}
              
              ;{ Spellchecking
              If GetGadgetState(#Gadget_Settings_OG_SpellCheck)
                AppReg::SetInteger(#AppReg, "Settings", "SpellCheck", #True)
                If GetGadgetText(#Gadget_Settings_CB_Dictionary)
                  AppReg::SetValue(#AppReg, "Settings", "Dictionary", GetGadgetText(#Gadget_Settings_CB_Dictionary))
                  EditEx::LoadDictionary(GetGadgetText(#Gadget_Settings_CB_Dictionary))
                  EditEx::EnableAutoSpellCheck(#True)
                EndIf 
              Else
                AppReg::SetInteger(#AppReg, "Settings", "SpellCheck", #False)
                EditEx::EnableAutoSpellCheck(#False)
              EndIf
              ;}
              
              quitWindow = #True
              ;}
          EndSelect
      EndSelect
    Until quitWindow
    
    CloseWindow(#Window_Settings)
  EndIf
  
EndProcedure  

;- __________ Main - Loop __________

Define.i quitWindow = #False
Define.s FileName$, File$, Path$, Code$, String$, Table$

AppReg::Open(#AppReg, "MarkdownEditor.reg", "MarkdownEditor", "Thorsten Hoeppner")

;{ Load language file
If LoadXML(#XML, "MarkdownEditor.lng")
  ExtractXMLMap(MainXMLNode(#XML), Language())
  FreeXML(#XML)
EndIf ;}

;{ Load dictionary
If AppReg::GetInteger(#AppReg, "Settings", "SpellCheck")
  If FileSize(AppReg::GetValue(#AppReg, "Settings", "Dictionary"))
    EditEx::LoadDictionary(AppReg::GetValue(#AppReg, "Settings", "Dictionary"))
    EditEx::EnableAutoSpellCheck(#True)
  EndIf
EndIf
;}

Code$ = AppReg::GetValue(#AppReg, "Settings", "Language", "GB") 
If FindMapElement(Language(), Code$)
  CopyMap(Language()\Strg(), Lng())
EndIf  

Window::Load("MarkdownEditor.win")

If Window_MarkDown()
  
  Window::RestoreSize(#Window_MarkDown)
  
  Repeat
    Select WaitWindowEvent()
      Case #PB_Event_CloseWindow   ;{ Close Window
        Select EventWindow()
          Case #Window_MarkDown
            quitWindow = #True
        EndSelect ;}
      Case #PB_Event_Menu
        Select EventMenu()
          Case #Menu_Copy          ;{ Copy & Paste
            EditEx::Copy(#Gadget_MarkDown_Editor)
          Case #Menu_Cut 
            EditEx:: Cut(#Gadget_MarkDown_Editor)
          Case #Menu_Paste
            EditEx::Paste(#Gadget_MarkDown_Editor)
            ;}  
          Case #Menu_H1            ;{ Headings
            PopupMenu_("# ", " #")
          Case #Menu_H2
            PopupMenu_("## ", " ##")
          Case #Menu_H3
            PopupMenu_("### ", " ###")
          Case #Menu_H4
            PopupMenu_("#### ", " ####")
          Case #Menu_H5
            PopupMenu_("##### ", " #####")
          Case #Menu_H6
            PopupMenu_("###### ", " ######")
            ;}
          Case #Menu_Code          ;{ Code
            PopupMenu_("`", "`")       
            ;}
          Case #Menu_Bold          ;{ Emphasis
            PopupMenu_("**", "**")
          Case #Menu_Italic
            PopupMenu_("*", "*")
          Case #Menu_BoldItalic
            PopupMenu_("***", "***")
          Case #Menu_Highlight
            PopupMenu_("==", "==")
            ;}
          Case #Menu_Strikethrough ;{ Strikethrough
            PopupMenu_("~~", "~~")
            ;}
          Case #Menu_SubScript     ;{ SubScript/SuperScript
            PopupMenu_("~", "~")
          Case #Menu_SuperScript
            PopupMenu_("^", "^")
            ;}
          Case #Menu_Keystroke     ;{ Keystroke
            PopupMenu_("[[", "]]")
            ;}  
          Case #Menu_Footnote      ;{ Footnote
            PopupMenu_("[^", "]")
            ;}
          Case #Menu_URL           ;{ URL/EMail
            PopupMenu_("<", ">")
            ;}
          Case #Menu_Link          ;{ Links
            PopupMenu_("[](", " " + #DQUOTE$ + #DQUOTE$ + ")")
          Case #Menu_LinkRef
            PopupMenu_("[", "][]")
            ;}
          Case #Menu_Image         ;{ Images
            PopupMenu_("![](", " " + #DQUOTE$ + #DQUOTE$ + ")")
          Case #Menu_ImageRef
            PopupMenu_("![", "][]")
            ;}
          Case #Menu_Abbreviation  ;{ Abbreviation
            PopupMenu_("*[", "]: ")
            ;}
          Case #Menu_Ref_Footnote  ;{ Reference
            PopupMenu_("[^", "]: ")
          Case #Menu_Ref_Image
            PopupMenu_("![", "]: ")
          Case #Menu_Ref_Link
            PopupMenu_("[", "]: ")
            ;}
          Case #Emoji_Bookmark     ;{ Emoji
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":bookMark:")
          Case #Emoji_Date
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":date:")
          Case #Emoji_Mail
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":mail:")
          Case #Emoji_Memo
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":memo:")
          Case #Emoji_Pencil
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":pencil:")
          Case #Emoji_Phone  
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":phone:")
          Case #Emoji_Bulb 
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":bulb:")
          Case #Emoji_Clip  
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":paperclip:")
          Case #Emoji_Magnifier
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":magnifier:")  
          Case #Emoji_Warning
            EditEx::InsertText(#Gadget_MarkDown_Editor, ":warning:")  
            ;}
        EndSelect    
      Case #PB_Event_Gadget
        Select EventGadget()
          Case #Gadget_MarkDown_Editor      ;{ Update
            Select EventType()
              Case EditEx::#EventType_NewLine  
                MarkDown::SetText(#Gadget_MarkDown_Viewer, EditEx::GetText(#Gadget_MarkDown_Editor))
              Case #PB_EventType_RightClick
                DisplayPopupMenu(#PopupMenu, WindowID(#Window_MarkDown))  
            EndSelect ;}
          Case #Gadget_MarkDown_Bt_New      ;{ New document
            New_(FileName$)
            FileName$ = ""
            ;}
          Case #Gadget_MarkDown_Bt_Open     ;{ Open document
            File$     = Load_()
            Path$     = GetPathPart(File$)
            FileName$ = GetFilePart(File$)
            ;}
          Case #Gadget_MarkDown_Bt_Save     ;{ Save document
            FileName$ = Save_(FileName$)
            ;}
          Case #Gadget_MarkDown_Bt_PDF      ;{ Export PDF
            MarkDown::Export(#Gadget_MarkDown_Viewer, MarkDown::#PDF, Path$ + "Export.pdf", "PDF")
            RunProgram(Path$ + "Export.pdf")
            ;}
           Case #Gadget_MarkDown_Bt_HTML    ;{ Export HTML
            MarkDown::Export(#Gadget_MarkDown_Viewer, MarkDown::#HTML, Path$ + "Export.html", "HTML")
            RunProgram(Path$ + "Export.html")
            ;} 
          Case #Gadget_MarkDown_Bt_Update   ;{ Update Markdown Gadget
            MarkDown::SetText(#Gadget_MarkDown_Viewer, EditEx::GetText(#Gadget_MarkDown_Editor))
            ;}
          Case #Gadget_MarkDown_Bt_Table    ;{ Insert Table
            Table$ = TableWindow()
            If Table$
              EditEx::InsertText(#Gadget_MarkDown_Editor, Table$)
            EndIf  
            ;}
          Case #Gadget_MarkDown_Bt_Settings ;{ Settings
            SettingsWindow()
            ;}
        EndSelect
    EndSelect
  Until quitWindow
  
  Window::Save("MarkdownEditor.win")
  
  CloseWindow(#Window_MarkDown)
EndIf

AppReg::Close(#AppReg)

End
; IDE Options = PureBasic 5.71 LTS (Windows - x64)
; CursorPosition = 687
; FirstLine = 259
; Folding = EMFGQCAAgG-
; EnableXP
; DPIAware
; UseIcon = Markdown.ico
; Executable = MarkdownEditor.exe