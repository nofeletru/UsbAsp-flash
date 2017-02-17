unit findchip;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, dom, utilfunc, lazUTF8;

type

  { TChipSearchForm }

  TChipSearchForm = class(TForm)
    Bevel1: TBevel;
    EditSearch: TEdit;
    Label1: TLabel;
    ListBoxChips: TListBox;
    procedure EditSearchChange(Sender: TObject);
    procedure ListBoxChipsDblClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

  procedure FindChip(XMLfile: TXMLDocument; chipname: string; chipid: string = '');

var
  ChipSearchForm: TChipSearchForm;

implementation

uses main;

{$R *.lfm}

//Ищет чип по имени. Если id не пустое то только по id.
procedure FindChip(XMLfile: TXMLDocument; chipname: string; chipid: string = '');
var
  Node, ChipNode: TDOMNode;
  j, i: integer;
  cs: string;
begin
  if XMLfile <> nil then
  begin
    Node := XMLfile.DocumentElement.FirstChild;

    while Assigned(Node) do
    begin
     //Node.NodeName; //Раздел(SPI, I2C...)

     // Используем свойство ChildNodes
     with Node.ChildNodes do
     try
       for j := 0 to (Count - 1) do
       begin
         //Item[j].NodeName; //Раздел Фирма

         for i := 0 to (Item[j].ChildNodes.Count - 1) do
         begin

           ChipNode := Item[j].ChildNodes.Item[i];
           if chipid <> '' then
           begin
             if (ChipNode.HasAttributes) then
               if  ChipNode.Attributes.GetNamedItem('id') <> nil then
               begin
                 cs := UTF16ToUTF8(ChipNode.Attributes.GetNamedItem('id').NodeValue); //id
                 if Upcase(cs) = Upcase(chipid) then
                   ChipSearchForm.ListBoxChips.Items.Append(UTF16ToUTF8(ChipNode.NodeName)+' ('+ UTF16ToUTF8(Item[j].NodeName) +')');
               end;
           end
           else
           begin
             cs := UTF16ToUTF8(ChipNode.NodeName); //Чип
             if pos(Upcase(chipname), Upcase(cs)) > 0 then
               ChipSearchForm.ListBoxChips.Items.Append(cs+' ('+ UTF16ToUTF8(Item[j].NodeName) +')');
           end;

         end;
       end;
     finally
       Free;
     end;
     Node := Node.NextSibling;
    end;
  end;
end;

procedure SelectChip(XMLfile: TXMLDocument; chipname: string);
var
  Node, ChipNode: TDOMNode;
  j, i: integer;
  cs: string;
begin
  if XMLfile <> nil then
  begin
    Node := XMLfile.DocumentElement.FirstChild;

    while Assigned(Node) do
    begin
     //Node.NodeName; //Раздел(SPI, I2C...)

     // Используем свойство ChildNodes
     with Node.ChildNodes do
     try
       for j := 0 to (Count - 1) do
       begin
         //Item[j].NodeName; //Раздел Фирма

         for i := 0 to (Item[j].ChildNodes.Count - 1) do
         begin
           cs := UTF16ToUTF8(Item[j].ChildNodes.Item[i].NodeName); //Чип
           if Upcase(chipname) = Upcase(cs) then
           begin
             ChipNode := Item[j].ChildNodes.Item[i];
             MainForm.LabelChipName.Caption := UTF16ToUTF8(ChipNode.NodeName);
             if (ChipNode.HasAttributes) then
             begin

               if  ChipNode.Attributes.GetNamedItem('spicmd') <> nil then
               begin
                 MainForm.RadioSPI.Checked:= true;
                 if UpperCase(ChipNode.Attributes.GetNamedItem('spicmd').NodeValue) = 'KB'then
                   MainForm.ComboSPICMD.ItemIndex:= SPI_CMD_KB;
                 if ChipNode.Attributes.GetNamedItem('spicmd').NodeValue = '45' then
                   MainForm.ComboSPICMD.ItemIndex:= SPI_CMD_45;
                 if ChipNode.Attributes.GetNamedItem('spicmd').NodeValue = '25' then
                   MainForm.ComboSPICMD.ItemIndex:= SPI_CMD_25;
                 if ChipNode.Attributes.GetNamedItem('spicmd').NodeValue = '95' then
                   MainForm.ComboSPICMD.ItemIndex:= SPI_CMD_95;
               end
               else //По дефолту spicmd25
               if (ChipNode.Attributes.GetNamedItem('addrtype') = nil) and
                     (ChipNode.Attributes.GetNamedItem('addrbitlen') = nil) then
                     begin
                        MainForm.RadioSPI.Checked:= true;
                        MainForm.ComboSPICMD.ItemIndex:= SPI_CMD_25;
                     end;

               if ChipNode.Attributes.GetNamedItem('addrbitlen') <> nil then
               begin
                 MainForm.RadioMw.Checked:= true;
                 MainForm.ComboMWBitLen.Text := UTF16ToUTF8(ChipNode.Attributes.GetNamedItem('addrbitlen').NodeValue)
               end
               else
                 MainForm.ComboMWBitLen.Text := 'MW addr len';

               if ChipNode.Attributes.GetNamedItem('addrtype') <> nil then
                 if IsNumber(UTF16ToUTF8(ChipNode.Attributes.GetNamedItem('addrtype').NodeValue)) then
                 begin
                   MainForm.RadioI2C.Checked:= true;
                   MainForm.ComboAddrType.ItemIndex := StrToInt(UTF16ToUTF8(ChipNode.Attributes.GetNamedItem('addrtype').NodeValue));
                 end;

               if  ChipNode.Attributes.GetNamedItem('page') <> nil then
                 MainForm.ComboPageSize.Text := UTF16ToUTF8(ChipNode.Attributes.GetNamedItem('page').NodeValue)
               else
                 MainForm.ComboPageSize.Text := 'Page size';

               if ChipNode.Attributes.GetNamedItem('size') <> nil then
                 MainForm.ComboChipSize.Text := UTF16ToUTF8(ChipNode.Attributes.GetNamedItem('size').NodeValue)
               else
                 MainForm.ComboChipSize.Text := 'Chip size';

              end;
           end;
         end;

       end;
     finally
       Free;
     end;
     Node := Node.NextSibling;
    end;
  end;
end;

{ TChipSearchForm }

procedure TChipSearchForm.EditSearchChange(Sender: TObject);
begin
  ListBoxChips.Clear;
  FindChip(chiplistfile, EditSearch.Text);
end;

procedure TChipSearchForm.ListBoxChipsDblClick(Sender: TObject);
var
  chipname: string;
begin
  if ListBoxChips.ItemIndex >= 0 then
  begin
    chipname := ListBoxChips.Items[ListBoxChips.ItemIndex];
    chipname := copy(chipname, 1, pos(' (', chipname)-1); //отрезаем фирму
    SelectChip(chiplistfile, chipname);
  end;
end;

end.

