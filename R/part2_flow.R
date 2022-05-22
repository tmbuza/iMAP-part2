library(DiagrammeR)
library(DiagrammeRsvg)

graph <- DiagrammeR::grViz("
digraph {
graph [layout = dot, rankdir = TD]

node [
shape = box, 
style = filled, 
fillcolor = white, 
fontname = Helvetica,
penwidth = 2.0] 

edge [arrowhead = diamond]

A [label = 'TAXONOMIC \nPROFILING OF \nMICROBIOME DATA', fillcolor = white, penwidth = 5.0]
B [label = 'Complex Data from \nSequencing Platforms\n(*.fastq.gz)', shape = folder]
C [label = '16S rRNA Gene Amplicon\nSequencing Data']
D [label = 'Metagenomics Shotgun\nSequencing Data']
E [label = 'Mothur\nPipeline', shape = oval]
F [label = 'QIIME2\nPipeline', shape = oval]
G [label = 'MetaPhlAn\nPipeline', shape = oval]
H [label = 'HUMAnN\nPipeline', shape = oval]
I [label = 'ASV/OTU &\nTaxonomy Tables']
J [label = 'Feature & Taxonomy\nTables']
K [label = 'Microbial\nProfiles']
L [label = 'MetaPhlAn\nBugs List']
M [label = 'Tidying Mothur, QIIME2,\nMetaPhlAn & HUMAnN Output', shape = oval, penwidth = 2.0]
N [label = 'TIDY MICROBIAL\nABUNDANCE\nTABLES', shape = diamond, fillcolor = yellow, penwidth = 4.0]

A [color = black]
C,E,F,I,J [color = limegreen]
D,G,H,K,L [color = dodgerblue]

{A}  -> B
{B}  -> C
{B}  -> D
{C}  -> E
{C}  -> F
{D}  -> G
{D}  -> H
{E}  -> I
{F}  -> J
{G}  -> K
{H}  -> L
{I}  -> M [arrowhead = vee]
{J}  -> M [arrowhead = vee]
{K}  -> M [arrowhead = vee]
{L}  -> M [arrowhead = vee]
{M}  -> N 


}", height = 500, width = 500)

# 2. Convert to SVG, then save as png
part2_flow = DiagrammeRsvg::export_svg(graph)
part2_flow = charToRaw(part2_flow) # flatten
rsvg::rsvg_png(part2_flow, "img/part2_flow.png")