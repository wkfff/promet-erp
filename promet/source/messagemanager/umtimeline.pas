{*******************************************************************************
  Copyright (C) Christian Ulrich info@cu-tec.de

  This source is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free
  Software Foundation; either version 2 of the License, or commercial alternative
  contact us for more information

  This code is distributed in the hope that it will be useful, but WITHOUT ANY
  WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
  details.

  A copy of the GNU General Public License is available on the World Wide Web
  at <http://www.gnu.org/copyleft/gpl.html>. You can also obtain it by writing
  to the Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
  MA 02111-1307, USA.
Created 07.10.2013
*******************************************************************************}
unit umtimeline;
{$mode objfpc}{$H+}
interface
uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, DBGrids,
  Buttons, Menus, ActnList, XMLPropStorage, StdCtrls, Utils, ZVDateTimePicker,
  uIntfStrConsts, db, memds, FileUtil, Translations, md5,
  ComCtrls, ExtCtrls, DbCtrls, Grids, uSystemMessage,ugridview,
  uExtControls,uBaseVisualControls,uBaseDbClasses,uFormAnimate,uBaseSearch,
  ImgList,uBaseDbInterface;
type

  { TMGridObject }

  TMGridObject = class(TObject)
  public
    Caption : string;
    Bold : Boolean;
    Text : string;
    HasAttachment : Boolean;
    IsThreaded : Boolean;
    Image : TBitmap;
    constructor Create;
    destructor Destroy; override;
  end;

  { TfmTimeline }

  TfmTimeline = class(TForm)
    acFollow: TAction;
    acRefresh: TAction;
    acSend: TAction;
    acAnswer: TAction;
    acDetailView: TAction;
    acMarkAllasRead: TAction;
    acMarkasRead: TAction;
    acAddUser: TAction;
    acAddImage: TAction;
    acAddScreenshot: TAction;
    acRights: TAction;
    acDelete: TAction;
    acViewThread: TAction;
    ActionList1: TActionList;
    bSend: TBitBtn;
    lbResults: TListBox;
    mEntry: TMemo;
    IdleTimer1: TIdleTimer;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem7: TMenuItem;
    miBugtracker: TMenuItem;
    miDeletemandant: TMenuItem;
    miNewMandant: TMenuItem;
    miProperties: TMenuItem;
    miRegister: TMenuItem;
    pInput: TPanel;
    Panel2: TPanel;
    PopupMenu1: TPopupMenu;
    pSearch: TPanel;
    sbAddScreenshot1: TSpeedButton;
    SelectDirectoryDialog1: TSelectDirectoryDialog;
    sbAddFile: TSpeedButton;
    sbAddScreenshot: TSpeedButton;
    tbRootEntrys: TSpeedButton;
    sbAddUser: TSpeedButton;
    tbThread: TSpeedButton;
    tbUser: TSpeedButton;
    Timer1: TTimer;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TSpeedButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    tsHistory: TTabSheet;
    procedure acAddScreenshotExecute(Sender: TObject);
    procedure acAnswerExecute(Sender: TObject);
    procedure acDeleteExecute(Sender: TObject);
    procedure acDetailViewExecute(Sender: TObject);
    procedure acFollowExecute(Sender: TObject);
    procedure acMarkAllasReadExecute(Sender: TObject);
    procedure acMarkasReadExecute(Sender: TObject);
    procedure acRefreshExecute(Sender: TObject);
    procedure acSendExecute(Sender: TObject);
    procedure ActiveSearchEndItemSearch(Sender: TObject);
    procedure ActiveSearchItemFound(aIdent: string; aName: string;
      aStatus: string; aActive: Boolean; aLink: string; aItem: TBaseDBList=nil);
    procedure bSendClick(Sender: TObject);
    function FContListDrawColumnCell(Sender: TObject; const aRect: TRect;
      DataCol: Integer; Column: TColumn; State: TGridDrawState): Boolean;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure fTimelineGetCellText(Sender: TObject; aCol: TColumn;
      aRow: Integer; var NewText: string; aFont: TFont);
    procedure fTimelinegetRowHeight(Sender: TObject; aCol: TColumn;
      aRow: Integer; var aHeight: Integer;var aWidth : Integer);
    procedure fTimelinegListDblClick(Sender: TObject);
    procedure fTimelinegListKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure IdleTimer1Timer(Sender: TObject);
    procedure lbResultsDblClick(Sender: TObject);
    procedure mEntryKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure mEntryKeyPress(Sender: TObject; var Key: char);
    procedure pSearchClick(Sender: TObject);
    procedure tbThreadClick(Sender: TObject);
    procedure tbUserClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ToolButton2Click(Sender: TObject);
    procedure tbRootEntrysClick(Sender: TObject);
  private
    { private declarations }
    ActiveSearch : TSearch;
    SysCommands : TSystemCommands;
    fTimeline : TfGridView;
    FDrawnDate : TDateTime;
    FParentItem : Variant;
    FOldBaseFilterU: String;
    FOldRecU: LargeInt;
    FOldBaseFilterT: String;
    FOldRecT: LargeInt;
    FOldSortT: String;
    FOldSortDT: uBasedbinterface.TSortDirection;
    FoldAutoFilterU : Boolean;
    FOldAutoFilterT : Boolean;
    FOldLimitT: Integer;
    FUserHist : TUser;
    function GetUsersFromString(var tmp : string) : TStringList;
    procedure MarkAsRead;
  public
    { public declarations }
    procedure Execute;
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    procedure ShowFrame;
  end;
var
  fmTimeline: TfmTimeline;
const
  DrawImageWidth = 150;
implementation
uses uBaseApplication, uData, uOrder,uMessages,uBaseERPDBClasses,
  uMain,LCLType,utask,uProcessManager,uprometipc,ProcessUtils,ufollow,udetailview,
  LCLIntf,wikitohtml,uDocuments,uthumbnails,uscreenshotmain;
resourcestring
  strTo                                  = 'an ';

constructor TMGridObject.Create;
begin
  Bold := False;
  Image := nil;
end;

destructor TMGridObject.Destroy;
begin
  if Assigned(Image) then
    Image.Free;
  inherited Destroy;
end;

procedure TfmTimeline.Execute;
var
  aBoundsRect: TRect;
begin
  if not Assigned(Self) then
    begin
      Application.CreateForm(TfmTimeline,fmTimeline);
      Self := fmTimeline;
      fTimeline.Parent := Panel2;
      fTimeline.Align := alClient;
      fTimeline.DefaultRows:='GLOBALWIDTH:430;TIMESTAMPD:100;ACTIONICON:30;ACTION:250;REFERENCE:50;';
      fTimeline.BaseName:='PTLINE';
      fTimeline.SortDirection:=sdDescending;
      fTimeline.SortField:='TIMESTAMPD';
      fTimeline.TextField:='ACTION';
      fTimeline.IdentField:='ACTION';
      fTimeLine.TreeField:='PARENT';
      fTimeline.FilterRow:=True;
      fTimeline.ReadOnly:=True;
      fTimeline.OnDrawColumnCell:=@FContListDrawColumnCell;
      fTimeline.OnGetCellText:=@fTimelineGetCellText;
      fTimeline.DataSet := TBaseHistory.Create(Self,Data);
      fTimeline.gList.OnKeyDown:=@fTimelinegListKeyDown;
      fTimeline.gList.OnDblClick:=@fTimelinegListDblClick;
      fTimeline.gList.Options:=fTimeline.gList.Options-[goVertLine];
      fTimeline.gHeader.Options:=fTimeline.gHeader.Options-[goVertLine];
      fTimeline.gList.PopupMenu := PopupMenu1;
      fTimeline.OnGetCellText:=@fTimelineGetCellText;
      fTimeline.OngetRowHeight:=@fTimelinegetRowHeight;
      fTimeline.WordWrap:=True;
      Data.SetFilter(fTimeline.DataSet,fMain.Filter+' '+fMain.Filter2,300);
      with Application as IBaseApplication do
        Config.ReadRect('TIMELINERECT',aBoundsRect,BoundsRect);
      fTimeline.Show;
      Show;
      BoundsRect := aBoundsRect;
      acDelete.Visible:=Data.Users.Rights.Right('HISTORY')>=RIGHT_DELETE;
    end;
  if fmTimeline.WindowState=wsMinimized then
    fmTimeline.WindowState:=wsNormal;
  Show;
  fTimeline.acFilter.Execute;
  //IdleTimer1.Enabled:=True;
  fTimeline.SetActive;
  fTimeline.gList.TopRow:=0;
end;

constructor TfmTimeline.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  fTimeline := TfGridView.Create(Self);
  fTimeline.ShowHint:=True;
end;

destructor TfmTimeline.Destroy;
begin
  inherited Destroy;
end;

procedure TfmTimeline.ShowFrame;
begin
end;

function TfmTimeline.FContListDrawColumnCell(Sender: TObject; const aRect: TRect;
  DataCol: Integer; Column: TColumn; State: TGridDrawState): Boolean;
const
  aTextStyle : TTextStyle = (Alignment:taLeftJustify;
                             Layout : tlTop;
                             SingleLine : False;
                             Clipping  : True;
                             ExpandTabs:False;
                             ShowPrefix:False;
                             Wordbreak:false;
                             Opaque:True;
                             SystemFont:False;
                             RightToLeft:False);
  aTextStyleW : TTextStyle = (Alignment:taLeftJustify;
                             Layout : tlTop;
                             SingleLine : false;
                             Clipping  : false;
                             ExpandTabs:False;
                             ShowPrefix:False;
                             Wordbreak:true;
                             Opaque:false;
                             SystemFont:False;
                             RightToLeft:False);
var
  aColor: TColor;
  aText: String;
  aHeight: Integer;
  aRRect: TRect;
  aMiddle: Integer;
  aObj: TObject;
  bRect: TRect;
  r: TRect;
  aEn: Boolean;
  cRect: TRect;
  aFactor: Extended;
begin
  with (Sender as TCustomGrid), Canvas do
    begin
      Result := True;
      Canvas.Font.Style := [];
      Canvas.FillRect(aRect);
      if gdSelected in State then
        Canvas.Font.Color:=clHighlightText
      else
        Canvas.Font.Color:=clWindowText;
      aColor := Column.Color;
      if (not (gdFixed in State)) and (TStringGrid(Sender).AlternateColor<>AColor) then
        begin
          if (TStringGrid(Sender).AltColorStartNormal and Odd(DataCol-TStringGrid(Sender).FixedRows)) {(1)} or
             (not TStringGrid(Sender).AltColorStartNormal and Odd(DataCol)) {(2)} then
            AColor := TStringGrid(Sender).AlternateColor;
        end;
      if (gdSelected in State) then
        begin
          aColor := TStringGrid(Sender).SelectedColor;
          TStringGrid(Sender).Canvas.Font.Color:=clHighlightText;
        end;
      if (Column.FieldName = 'ACTIONICON') then
        begin
          Canvas.Brush.Color:=aColor;
          Canvas.FillRect(aRect);
          Canvas.Pen.Color:=clGray;
          aMiddle :=((aRect.Right-aRect.Left) div 2);
          Canvas.MoveTo(aRect.Left+aMiddle,aRect.Top);
          Canvas.LineTo(aRect.Left+aMiddle,aRect.Bottom);
          aHeight := 14;
          aRRect := Rect(aRect.left+(aMiddle-(aHeight div 2)),
                         aRect.Top+((aRect.Bottom-aRect.Top) div 2)-(aHeight div 2),
                         aRect.left+(aMiddle+(aHeight div 2)),
                         aRect.Top+((aRect.Bottom-aRect.Top) div 2)+(aHeight div 2));
          Canvas.Ellipse(aRRect);
          if not (TExtStringGrid(Sender).Cells[Column.Index+1,DataCol] = '') then
            begin
              aObj := fTimeline.gList.Objects[Column.Index+1,DataCol];
              fVisualControls.HistoryImages.StretchDraw(Canvas,StrToIntDef(TExtStringGrid(Sender).Cells[Column.Index+1,DataCol],-1),aRRect);// Draw(Canvas,Rect.Left,Rect.Top,);
            end;
          if (gdSelected in State) and TStringGrid(Sender).Focused then
            TStringGrid(Sender).Canvas.DrawFocusRect(arect);
        end
      else if (Column.FieldName = 'REFOBJECT') or (Column.FieldName = 'OBJECT') then
        begin
          with Application as IBaseDbInterface do
            aText := Data.GetLinkDesc(TExtStringGrid(Sender).Cells[Column.Index+1,DataCol]);
          with TStringGrid(Sender).Canvas do
            begin
              TStringGrid(Sender).Canvas.Brush.Color:=aColor;
              FillRect(aRect);
            end;
          TStringGrid(Sender).Canvas.Brush.Style:=bsClear;
          aTextStyle.Alignment:=Column.Alignment;
          TextRect(aRect,aRect.Left+3,aRect.Top,aText,aTextStyle);
          Result := True;
        end
      else if (Column.FieldName='ACTION') then
        begin
          aObj := fTimeline.gList.Objects[Column.Index+1,DataCol];
          if Assigned(aObj) then
            begin
              result := True;
              if TMGridObject(aObj).Bold then
                begin
                  Canvas.Brush.Color := clHighlight;
                  bRect := aRRect;
                  bRect.Right := bRect.Left+4;
                  Canvas.Rectangle(bRect);
                end;
              if TMGridObject(aObj).Text='' then
                TMGridObject(aObj).Text := copy(StripWikiText(TExtStringGrid(Sender).Cells[Column.Index+1,DataCol]),0,1000);
              atext := TMGridObject(aObj).Text;
              TStringGrid(Sender).Canvas.Brush.Color:=aColor;
              TStringGrid(Sender).Canvas.FillRect(aRect);
              TStringGrid(Sender).Canvas.Brush.Style:=bsClear;
              bRect := aRect;
              if TMGridObject(aObj).IsThreaded then
                fVisualControls.Images.Draw(TStringGrid(Sender).Canvas,aRect.Left-16,aRect.Top+16,112);
              if TMGridObject(aObj).HasAttachment then
                begin
                  fVisualControls.Images.Draw(TStringGrid(Sender).Canvas,aRect.Left-16,aRect.Top,70);
                  bRect.Right:=bRect.Right-DrawImageWidth;
                  if Assigned(TMGridObject(aObj).Image) then
                    begin
                      cRect := Rect(bRect.Right,bRect.Top,aRect.Right,0);
                      aFactor := TMGridObject(aObj).Image.Width/TMGridObject(aObj).Image.Height;
                      if TMGridObject(aObj).Image.Width>TMGridObject(aObj).Image.Height then
                        cRect.Bottom:=round(cRect.Top+(DrawImageWidth/aFactor))
                      else cRect.Bottom:=round(cRect.Top+(DrawImageWidth * aFactor));
                      TStringGrid(Sender).Canvas.StretchDraw(cRect,TMGridObject(aObj).Image);
                    end;
                end;
              if TMGridObject(aObj).Caption <> '' then
                brect.Top := bRect.Top+TStringGrid(Sender).Canvas.TextExtent('A').cy;
              if TMGridObject(aObj).Bold then
                TStringGrid(Sender).Canvas.Font.Style := [fsBold];
              if fTimeline.WordWrap then
                TStringGrid(Sender).Canvas.TextRect(bRect,aRect.Left+3,bRect.Top,UTF8ToSys(aText),aTextStyleW)
              else
                TStringGrid(Sender).Canvas.TextRect(bRect,aRect.Left+3,bRect.Top,UTF8ToSys(aText),aTextStyle);
              bRect := aRect;
              TStringGrid(Sender).Canvas.Font.Color:=clGray;
              brect.Bottom := aRect.Top+Canvas.TextExtent('A').cy;
              TStringGrid(Sender).Canvas.Font.Style := [];
              TStringGrid(Sender).Canvas.TextOut(arect.Left+3,aRect.Top,TMGridObject(aObj).Caption);
              if (gdSelected in State) and TStringGrid(Sender).Focused then
                TStringGrid(Sender).Canvas.DrawFocusRect(arect);
            end
          else result := False;
        end
      else
        begin
          Result := False;
        end;
    end;
end;

procedure TfmTimeline.acRefreshExecute(Sender: TObject);
begin
  FTimeLine.Refresh(True);
end;

procedure TfmTimeline.acFollowExecute(Sender: TObject);
begin
  if fFollow.Execute then
    begin
      tbUser.Down:=False;
      tbThread.Down:=False;
      tbRootEntrys.Down:=False;
      fMain.RefreshFilter2;
      Data.SetFilter(fTimeline.DataSet,fMain.Filter+' '+fMain.Filter2,300);
      acRefresh.Execute;
    end;
end;

procedure TfmTimeline.acMarkAllasReadExecute(Sender: TObject);
begin
  fTimeline.DataSet.First;
  while not fTimeline.DataSet.EOF do
    begin
      MarkAsRead;
      fTimeline.DataSet.Next;
    end;
end;

procedure TfmTimeline.acMarkasReadExecute(Sender: TObject);
begin
  if fTimeline.GotoActiveRow then
    MarkAsRead;
end;

procedure TfmTimeline.acAnswerExecute(Sender: TObject);
var
  tmp: String;
begin
  Application.ProcessMessages;
  if fTimeline.GotoActiveRow then
    begin
      if ((fTimeline.DataSet.FieldByName('LINK').AsString <> '')
      and (fTimeline.DataSet.FieldByName('ACTIONICON').AsString <> '8'))
      and (Sender = nil)
      then
        begin
          if not ProcessExists('prometerp'+ExtractFileExt(Application.ExeName)) then
            begin
              ExecProcess(AppendPathDelim(ExpandFileName(AppendPathdelim(Application.Location) + '..'))+'prometerp'+ExtractFileExt(Application.ExeName),'',False);
            end;
          SendIPCMessage('OpenLink('+fTimeline.DataSet.FieldByName('LINK').AsString+')');
        end
      else
        begin
          tmp := fTimeline.DataSet.FieldByName('REFERENCE').AsString;
          if trim(tmp)='' then
            tmp := fTimeline.DataSet.FieldByName('CHANGEDBY').AsString;
          mEntry.Lines.Text:='@'+tmp+' ';
          mEntry.SelStart:=length(mEntry.Lines.Text);
          ToolButton2.Down:=True;
          ToolButton2Click(ToolButton2);
        end;
      FParentItem := fTimeline.DataSet.Id.AsVariant;
      MarkAsRead;
    end;
end;

procedure TfmTimeline.acDeleteExecute(Sender: TObject);
begin
  if fTimeline.GotoActiveRow then
    begin
      fTimeline.Delete;
    end;
end;

procedure TfmTimeline.acAddScreenshotExecute(Sender: TObject);
var
  aDocuments: TDocuments;
  aDocument: TDocument;
  aDocPage: TTabSheet;
  aName : string = 'screenshot.jpg';
  aPageIndex: Integer;
  aUsers: TStringList;
  tmp: TCaption;
  i: Integer;
  Found: Boolean = False;
  aId : Variant;
begin
  tmp := mEntry.Lines.Text;
  aUsers := GetUsersFromString(tmp);
  FUserHist := TUser.Create(nil,Data);
  for i := 0 to aUsers.Count-1 do
    begin
      Data.SetFilter(FUserHist,Data.QuoteField('IDCODE')+'='+Data.QuoteValue(aUsers[i]));
      if FUserHist.Count=0 then
        begin
          Data.SetFilter(FUserHist,'',0);
          if not FUserHist.DataSet.Locate('IDCODE',aUsers[i],[loCaseInsensitive]) then
            FUserHist.DataSet.Close;
        end;
      if FUserHist.Count>0 then
        begin
          Found := True;
          FUserHist.History.AddParentedItem(FUserHist.DataSet,tmp,FParentItem,'',Data.Users.IDCode.AsString,nil,ACICON_USEREDITED,'',True,True);
        end;
    end;
  if not Found then
    begin
      FUserHist.Select(Data.Users.Id.AsVariant);
      FUserHist.Open;
      FUserHist.History.AddItem(Data.Users.DataSet,mEntry.Lines.Text,'','',nil,ACICON_USEREDITED,'',True,True);
    end;
  if FUserHist.History.CanEdit then
    FUserHist.History.Post;
  aUsers.Free;
  aId := FUserHist.History.Id.AsVariant;
  Application.ProcessMessages;
  Self.Hide;
  Application.ProcessMessages;
  //aName := InputBox(strScreenshotName, strEnterAnName, aName);
  Application.ProcessMessages;
  acSend.Enabled:=False;
  Application.CreateForm(TfScreenshot,fScreenshot);
  fScreenshot.SaveTo:=AppendPathDelim(GetTempDir)+aName;
  fScreenshot.Show;
  while fScreenshot.Visible do Application.ProcessMessages;
  fScreenshot.Destroy;
  fScreenshot := nil;
  aDocument := TDocument.Create(Self,Data);
  aDocument.Select(aId,'H',0);
  aDocument.AddFromFile(AppendPathDelim(GetTempDir)+aName);
  aDocument.Free;
  mEntry.SelText := '[[Bild:'+aName+']]';
  mEntry.SelStart:=mEntry.SelStart+length(mEntry.SelText);
  Self.Show;
  acSend.Enabled:=True;
end;

procedure TfmTimeline.acDetailViewExecute(Sender: TObject);
begin
  if fTimeline.GotoActiveRow then
    fDetailView.Execute(TBaseHistory(fTimeline.DataSet));
end;

procedure TfmTimeline.acSendExecute(Sender: TObject);
var
  tmp: String;
  aUser: TUser;
  aUsers : TStringList;
  i: Integer;
  Found: Boolean;
  AddTask: Boolean = False;
  aTask: TTask;
begin
  tmp := trim(mEntry.Lines.Text);
  if lowercase(copy(tmp,0,4)) = 'task' then
    begin
      tmp := trim(copy(tmp,5,length(tmp)));
      AddTask := True;
    end;
  if copy(tmp,0,1) = '@' then
    begin
      Found := False;
      tmp := copy(tmp,2,length(tmp));
      aUsers := GetUsersFromString(tmp);
      aUser := TUser.Create(nil,Data);
      for i := 0 to aUsers.Count-1 do
        begin
          Data.SetFilter(aUser,Data.QuoteField('IDCODE')+'='+Data.QuoteValue(aUsers[i]));
          if aUser.Count=0 then
            begin
              Data.SetFilter(aUser,'',0);
              if not aUser.DataSet.Locate('IDCODE',aUsers[i],[loCaseInsensitive]) then
                aUser.DataSet.Close;
            end;
          if aUser.Count>0 then
            begin
              Found := True;
              if not AddTask then
                begin
                  if Assigned(FUserHist) then
                    begin
                      FUserHist.History.Edit;
                      FUserHist.History.FieldByName('ACTION').AsString:=tmp;
                      FUserHist.History.Post;
                      FreeAndNil(FUserHist);
                    end
                  else
                    aUser.History.AddParentedItem(aUser.DataSet,tmp,FParentItem,'',Data.Users.IDCode.AsString,nil,ACICON_USEREDITED,'',True,True)
                end
              else
                begin
                  aTask := TTask.Create(nil,Data);
                  aTask.Insert;
                  aTask.FieldByName('SUMMARY').AsString:=tmp;
                  aTask.FieldByName('USER').AsString:=aUser.FieldByName('ACCOUNTNO').AsString;
                  aTask.DataSet.Post;
                  aTask.Free;
                end;
            end;
        end;
      aUser.Free;
    end
  else
    begin
      if Assigned(FUserHist) then
        begin
          FUserHist.History.Edit;
          FUserHist.History.FieldByName('ACTION').AsString:=tmp;
          FUserHist.History.Post;
          FreeAndNil(FUserHist);
        end
      else
        Data.Users.History.AddItem(Data.Users.DataSet,mEntry.Lines.Text,'','',nil,ACICON_USEREDITED,'',True,True);
      Found := True;
    end;
  fTimeline.Refresh;
  if Found then
    begin
      mEntry.Lines.Clear;
      ToolButton2.Down:=False;
      ToolButton2Click(ToolButton2);
      fTimeline.SetActive;
    end;
end;

procedure TfmTimeline.ActiveSearchEndItemSearch(Sender: TObject);
begin
  if not ActiveSearch.Active then
    begin
      if ActiveSearch.Count=0 then
        pSearch.Visible:=False;
    end;
end;

procedure TfmTimeline.ActiveSearchItemFound(aIdent: string; aName: string;
  aStatus: string; aActive: Boolean; aLink: string; aItem: TBaseDBList=nil);
begin
  with pSearch do
    begin
      if not Visible then
        Visible := True;
    end;
  if aActive then
    lbResults.Items.AddObject(aName,TLinkObject.Create(aLink));
end;

procedure TfmTimeline.bSendClick(Sender: TObject);
begin

end;
procedure TfmTimeline.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  IdleTimer1.Enabled:=False;
  with Application as IBaseApplication do
    Config.WriteRect('TIMELINERECT',BoundsRect);
  CloseAction:=caHide;
end;

procedure TfmTimeline.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    begin
      if (pInput.Visible) and (pInput.Height>5) then exit;
      pSearch.Visible:=False;
      Close;
    end;
end;

procedure TfmTimeline.FormShow(Sender: TObject);
begin
  Timer1.Enabled:=True;
end;

procedure TfmTimeline.fTimelineGetCellText(Sender: TObject; aCol: TColumn;
  aRow: Integer; var NewText: string; aFont: TFont);
var
  aTime: TDateTime;
  fhasObject: Boolean;
  i: Integer;
  aObj: TObject;
  arec: LargeInt;
  aDocument: TDocument;
begin
  if aCol.FieldName='LINK' then
    NewText := Data.GetLinkDesc(NewText)
  else if aCol.FieldName='OBJECT' then
    NewText := Data.GetLinkDesc(NewText)
  else if (aCol.FieldName='ACTION') then
    begin
      fHasObject := False;
      for i := 0 to fTimeline.dgFake.Columns.Count-1 do
        if fTimeline.dgFake.Columns[i].FieldName='OBJECT' then
          FHasObject := True;
      NewText := StripWikiText(NewText);
      if (not fHasObject) and (aRow>=fTimeLine.gList.FixedRows) then
        begin
          aObj := fTimeline.gList.Objects[aCol.Index+1,aRow];
          if not Assigned(aObj) then
            begin
              fTimeline.gList.Objects[aCol.Index+1,aRow] := TMGridObject.Create;
              arec := fTimeline.DataSet.GetBookmark;
              aObj := fTimeline.gList.Objects[aCol.Index+1,aRow];
              if fTimeline.GotoRowNumber(aRow) then
                begin
                  if fTimeline.dgFake.DataSource.DataSet.FieldByName('OBJECT').AsString <> Data.BuildLink(Data.Users.dataSet) then
                    begin
                      if copy(fTimeline.dgFake.DataSource.DataSet.FieldByName('OBJECT').AsString,0,6) = 'USERS@' then
                        TMGridObject(aObj).Caption := strTo+Data.GetLinkDesc(fTimeline.dgFake.DataSource.DataSet.FieldByName('OBJECT').AsString)
                      else
                        TMGridObject(aObj).Caption := Data.GetLinkDesc(fTimeline.dgFake.DataSource.DataSet.FieldByName('OBJECT').AsString);
                      fTimeline.gList.RowHeights[aRow] := fTimeline.gList.RowHeights[aRow]+12;
                    end;
                  TMGridObject(aObj).Bold:=(fTimeline.dgFake.DataSource.DataSet.FieldByName('READ').AsString<>'Y');
                  if fTimeline.dgFake.DataSource.DataSet.RecordCount>0 then
                    begin
                      aDocument := TDocument.Create(nil,Data);
                      aDocument.Select(fTimeline.dgFake.DataSource.DataSet.FieldByName('SQL_ID').AsVariant,'H',0);
                      aDocument.ActualLimit:=1;
                      aDocument.Open;
                      TMGridObject(aObj).HasAttachment := aDocument.Count>0;
                      TMGridObject(aObj).IsThreaded:=not fTimeline.dgFake.DataSource.DataSet.FieldByName('PARENT').IsNull;
                      if aDocument.Count>0 then
                        begin
                          TMGridObject(aObj).Image := GetThumbnailBitmap(aDocument);
                        end;
                      aDocument.Free;
                    end;
                end;
              fTimeline.DataSet.GotoBookmark(aRec);
            end;
          NewText := TMGridObject(aObj).Caption+lineending+NewText;
          if length(NewText)>1000 then
            NewText:=copy(NewText,0,1000)+LineEnding+'...';
        end;
    end
  else if aCol.FieldName='TIMESTAMPD' then
    begin
      aObj := fTimeline.gList.Objects[aCol.Index+1,aRow];
      if Assigned(aObj) then
        begin
          if TMGridObject(aObj).Bold then
            TStringGrid(Sender).Canvas.Font.Style:=[fsBold]
          else
            TStringGrid(Sender).Canvas.Font.Style:=[];
        end;
      if TryStrToDateTime(NewText,aTime) then
        begin
          if (trunc(aTime) = FDrawnDate) or (trunc(aTime) = trunc(Now())) then
            NewText:=TimeToStr(frac(aTime))
          else
            FDrawnDate:=trunc(aTime);
          aCol.Alignment:=taRightJustify;
        end;
    end;
end;

procedure TfmTimeline.fTimelinegetRowHeight(Sender: TObject; aCol: TColumn;
  aRow: Integer; var aHeight: Integer; var aWidth: Integer);
var
  aObj: TObject;
begin
  aHeight := aHeight+3;
  aObj := fTimeline.gList.Objects[aCol.Index+1,aRow];
  if Assigned(aObj) then
    begin
      if TMGridObject(aObj).HasAttachment
      and Assigned(TMGridObject(aObj).Image)
      and (TMGridObject(aObj).Image.Width>0) then
        aWidth := aWidth-TMGridObject(aObj).Image.Width div 2;
    end;
end;

procedure TfmTimeline.fTimelinegListDblClick(Sender: TObject);
begin
  acAnswerExecute(nil);
end;

procedure TfmTimeline.fTimelinegListKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i: Integer;
begin
  if Key = VK_INSERT then
    begin
      ToolButton2.Down:=True;
      ToolButton2Click(ToolButton2);
    end
  else fTimeline.gListKeyDown(Sender,Key,Shift);
  if Key = VK_G then
    begin
      if fTimeline.GotoActiveRow then
        begin
          MarkAsRead;
          fTimeline.gList.Row:=fTimeline.gList.Row+1;
        end;
    end;
end;

procedure TfmTimeline.IdleTimer1Timer(Sender: TObject);
begin
  FTimeLine.Refresh(True);
end;

procedure TfmTimeline.lbResultsDblClick(Sender: TObject);
var
  aUser: TUser;
  aText: TCaption;
begin
  if lbResults.ItemIndex = -1 then exit;
  aUser := TUser.Create(nil,data);
  aUser.SelectFromLink(TLinkObject(lbResults.Items.Objects[lbResults.ItemIndex]).Link);
  aUser.Open;
  aText := mEntry.Text;
  if pos(',',atext)>0 then
    aText := copy(aText,0,rpos(',',aText))
  else if pos('@',atext)>0 then
    aText := copy(aText,0,pos('@',aText));
  atext := atext+aUser.IDCode.AsString;
  mEntry.Text:=aText;
  mEntry.SelStart:=length(atext);
  pSearch.Visible:=False;
  aUser.Free;
end;

procedure TfmTimeline.mEntryKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if pSearch.Visible then
    begin
      case Key of
      VK_PRIOR,
      VK_UP:
        begin
          if lbResults.ItemIndex = -1 then
            begin
              lbResults.ItemIndex:=0;
              pSearch.Visible := False;
            end
          else
            begin
              lbResults.ItemIndex:=lbResults.ItemIndex-1;
              Key := 0;
            end;
        end;
      VK_NEXT,
      VK_DOWN:
        begin
          if lbResults.ItemIndex = -1 then
            lbResults.ItemIndex:=0
          else
          if lbResults.ItemIndex < lbResults.Count-1 then
            lbResults.ItemIndex:=lbResults.ItemIndex+1;
          Key := 0;
        end;
      VK_RETURN:
        begin
          lbResultsDblClick(nil);
          Key := 0;
        end;
      VK_ESCAPE:
        begin
          pSearch.Visible:=False;
          Key := 0;
        end;
      end;
    end
  else
    begin
      if (ssCtrl in Shift)
      and (Key = VK_RETURN) then
        begin
          mEntry.Text:=mEntry.Text+LineEnding;
        end
      else if Key = VK_ESCAPE then
        begin
          ToolButton2.Down:=false;
          ToolButton2Click(ToolButton2);
          Key := 0;
          if fTimeline.Visible then
            fTimeline.SetActive;
        end;
    end;
end;

procedure TfmTimeline.mEntryKeyPress(Sender: TObject; var Key: char);
var
  SearchTypes : TFullTextSearchTypes = [];
  SearchLocations : TSearchLocations;
  i: Integer;
  aText: TCaption;
begin
  if (((key = '@')
  or ((Key=',') and (pos(' ',mEntry.Text)=0))
  or ((Key = #8) and (copy(mEntry.Text,0,1)='@'))
  ) and (pSearch.Visible=False))
  then
    begin
      pSearch.Visible:=True;
    end
  else if pSearch.Visible then
    begin
      aText := mEntry.text;
      if pos(',',atext)>0 then
        aText := copy(aText,rpos(',',aText)+1,length(aText))
      else if pos('@',atext)>0 then
        aText := copy(aText,pos('@',aText)+1,length(atext));
      if trim(atext)='' then exit;
      if Assigned(ActiveSearch) then
        ActiveSearch.Abort;
      SearchTypes := SearchTypes+[fsShortnames];
      SearchTypes := SearchTypes+[fsIdents];
      SetLength(SearchLocations,length(SearchLocations)+1);
      SearchLocations[length(SearchLocations)-1] := strUsers;
      for i := 0 to lbResults.Items.Count-1 do
        lbResults.Items.Objects[i].Free;
      lbResults.Items.Clear;
      if not Assigned(ActiveSearch) then
        ActiveSearch := TSearch.Create(SearchTypes,SearchLocations,True,5);
      ActiveSearch.Sender := TComponent(Sender);
      ActiveSearch.OnItemFound:=@ActiveSearchItemFound;
      ActiveSearch.OnEndSearch:=@ActiveSearchEndItemSearch;
      ActiveSearch.Start(aText+Key);
      Application.ProcessMessages;
    end;
end;

procedure TfmTimeline.pSearchClick(Sender: TObject);
begin

end;

procedure TfmTimeline.tbThreadClick(Sender: TObject);
var
  FRoot : Variant;
begin
  Screen.Cursor:=crHourGlass;
  tbRootEntrys.Down:=False;
  fTimeline.ApplyAutoFilter:=True;
  if tbThread.Down then
    begin
      fTimeline.GotoActiveRow;
      FOldBaseFilterT := fTimeline.BaseFilter;
      FOldRecT := fTimeline.DataSet.GetBookmark;
      FOldSortT := fTimeline.SortField;
      FOldSortDT := fTimeline.SortDirection;
      FOldAutoFilterT := fTimeline.ApplyAutoFilter;
      FOldLimitT := fTimeline.DataSet.ActualLimit;
      FRoot := fTimeline.DataSet.FieldByName('ROOT').AsVariant;
      if FRoot = Null then
        FRoot := fTimeline.DataSet.FieldByName('PARENT').AsVariant;
      if FRoot = Null then
        FRoot := fTimeline.DataSet.FieldByName('SQL_ID').AsVariant;
      fTimeline.ApplyAutoFilter:=False;
      fTimeline.SortField:='TIMESTAMPD';
      fTimeline.SortDirection:=sdAscending;
      fTimeline.DataSet.ActualLimit:=0;
      fTimeline.DataSet.ActualFilter:='';
      fTimeline.BaseFilter:='('+Data.QuoteField('ROOT')+'='+Data.QuoteValue(FRoot)+') OR ('+Data.QuoteField('PARENT')+'='+Data.QuoteValue(FRoot)+') OR ('+Data.QuoteField('SQL_ID')+'='+Data.QuoteValue(FRoot)+')';
    end
  else
    begin
      fTimeline.DataSet.ActualFilter:=fMain.Filter+' '+fMain.Filter2;
      fTimeline.ApplyAutoFilter:=FOldAutoFilterT;
      fTimeline.SortField := FOldSortT;
      fTimeline.SortDirection := FOldSortDT;
      fTimeline.DataSet.ActualLimit:=FOldLimitT;
      if FOldBaseFilterT<>'' then
        begin
          fTimeline.BaseFilter:=FOldBaseFilterT;
          FOldBaseFilterT:='';
        end
      else
        fTimeline.BaseFilter:='';
      if FOldRecT<>0 then
        begin
          fTimeline.DataSet.GotoBookmark(FOldRecT);
          fTimeline.GotoDataSetRow;
          FOldRecT:=0;
        end;
      fTimeline.GotoDataSetRow;
    end;
  acMarkAllasRead.Visible:=tbThread.Down or tbUser.Down;
  Screen.Cursor:=crDefault;
end;

procedure TfmTimeline.tbUserClick(Sender: TObject);
var
  FUser: String;
begin
  Screen.Cursor:=crHourGlass;
  if tbRootEntrys.Down then
    tbRootEntrys.Down:=False;
  if tbUser.Down then
    begin
      fTimeline.GotoActiveRow;
      FOldBaseFilterU := fTimeline.BaseFilter;
      FOldRecU := fTimeline.DataSet.GetBookmark;
      FUser := fTimeline.DataSet.FieldByName('REFERENCE').AsString;
      FOldAutoFilterU := fTimeline.ApplyAutoFilter;
      fTimeline.ApplyAutoFilter:=False;
      fTimeline.BaseFilter:='('+Data.QuoteField('REFERENCE')+'='+Data.QuoteValue(FUser)+')';
    end
  else
    begin
      fTimeline.DataSet.ActualLimit:=100;
      fTimeline.ApplyAutoFilter:=FoldAutoFilterU;
      if FOldBaseFilterU<>'' then
        begin
          fTimeline.BaseFilter:=FOldBaseFilterU;
          FOldBaseFilterU:='';
        end
      else
        fTimeline.BaseFilter:='';
      if FOldRecU<>0 then
        begin
          fTimeline.DataSet.GotoBookmark(FOldRecU);
          fTimeline.GotoDataSetRow;
          FOldRecU:=0;
        end;
      fTimeline.GotoDataSetRow;
    end;
  acMarkAllasRead.Visible:=tbThread.Down or tbUser.Down;
  Screen.Cursor:=crDefault;
end;

procedure TfmTimeline.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled:=False;
  acRefresh.Execute;
end;

procedure TfmTimeline.ToolButton2Click(Sender: TObject);
var
  aController: TAnimationController;
begin
  FParentItem:=Null;
  FreeAndNil(FUserHist);
  aController := TAnimationController.Create(pInput);
  if ToolButton2.Down then
    begin
      pInput.Height := 0;
      pInput.Visible:=True;
      aController.AnimateControlHeight(110);
      mEntry.SetFocus;
    end
  else
    begin
      aController.AnimateControlHeight(0);
      pSearch.Visible:=False;
      if Assigned(FUserHist) then
        begin
          FUserHist.History.Delete;
          FreeAndNil(FUserHist);
        end;
      mEntry.Lines.Clear;
    end;
  aController.Free;
end;

procedure TfmTimeline.tbRootEntrysClick(Sender: TObject);
var
  FRoot : Variant;
begin
  Screen.Cursor:=crHourGlass;
  fTimeline.ApplyAutoFilter:=True;
  tbThread.Down:=False;
  tbUser.Down:=False;
  if tbRootEntrys.Down then
    begin
      fTimeline.GotoActiveRow;
      FRoot := fTimeline.DataSet.FieldByName('ROOT').AsVariant;
      if FRoot = Null then
        FRoot := fTimeline.DataSet.FieldByName('PARENT').AsVariant;
      fTimeline.DataSet.ActualLimit:=100;
      fTimeline.BaseFilter:=Data.ProcessTerm(Data.QuoteField('PARENT')+'='+Data.QuoteValue(''));
    end
  else
    fTimeline.BaseFilter:='';
  Screen.Cursor:=crDefault;
end;

function TfmTimeline.GetUsersFromString(var tmp: string): TStringList;
begin
  Result := TStringList.Create;
  while (pos(',',tmp) > 0) and (pos(',',tmp) < pos(' ',tmp)) do
    begin
      Result.Add(copy(tmp,0,pos(',',tmp)-1));
      tmp := copy(tmp,pos(',',tmp)+1,length(tmp));
    end;
  if pos(' ',tmp)>1 then
    result.Add(copy(tmp,0,pos(' ',tmp)-1));
  tmp := copy(tmp,pos(' ',tmp)+1,length(tmp));
end;

procedure TfmTimeline.MarkAsRead;
var
  i: Integer;
begin
  with fTimeline.DataSet.DataSet as IBaseManageDB do
    UpdateStdFields:=False;
  if not fTimeline.DataSet.CanEdit then
    fTimeline.DataSet.DataSet.Edit;
  fTimeline.DataSet.FieldByName('READ').AsString:='Y';
  fTimeline.DataSet.post;
  with fTimeline.DataSet.DataSet as IBaseManageDB do
    UpdateStdFields:=True;
  for i := 0 to fTimeline.dgFake.Columns.Count-1 do
    if fTimeline.dgFake.Columns[i].FieldName='ACTION' then
      begin
        TMGridObject(fTimeline.gList.Objects[i+1,fTimeline.gList.Row]).Bold:=False;
      end;
  fTimeline.gList.Invalidate;
end;

initialization
  {$I umtimeline.lrs}
  AddSearchAbleDataSet(TUser);

end.
