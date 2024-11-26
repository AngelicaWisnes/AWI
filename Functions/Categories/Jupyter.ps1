
#############################
# Jupyter-related functions #
#############################
function Open-JupyterNotebook { jupyter notebook }
Set-Alias jn Open-JupyterNotebook
Add-ToFunctionList -category 'Jupyter' -name 'jn' -value 'Open_Jupyter_Notebook'


function Get-JupyterOutputSizeCode {
  Set-Clipboard -Value "# Utility code to extend the height of output-cells
  from IPython.core.display import display, HTML
  # To change size of output-cell:         Change height here, Change width here
  display(HTML('<style>div.output_scroll {    height: 80em;       width: 80em;   }</style>'))"
}
Set-Alias jns Get-JupyterOutputSizeCode
Add-ToFunctionList -category 'Jupyter' -name 'jns' -value 'Get jupiter output-size-code'
