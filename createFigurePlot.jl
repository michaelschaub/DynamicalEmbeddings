## script file to analyse faculty_hiring network 
using Plots
using LaTeXStrings
using DelimitedFiles
using SparseArrays
using LinearAlgebra
using StatsBase
Plots.pyplot()

case = "CS" #Name suffix of output files 
# data location -- adjust to analyse other datasets (History, Business)
filename_edges = "./data/ComputerScience_edgelist.txt"
filename_nodes = "./data/ComputerScience_vertexlist.txt"

########################### 
# Construction of networks
###########################

# read in data
EdgeData = readdlm(filename_edges,skipstart=1)
NodeData = readdlm(filename_nodes,'\t',skipstart=1)
NodeNames = NodeData[:,6]

# create network
source_nodes = EdgeData[:,1]
target_nodes = EdgeData[:,2]

max_source = maximum(source_nodes)
max_target = maximum(target_nodes)
num_nodes = maximum([max_target,max_source])

Adj = Matrix(sparse(source_nodes,target_nodes,1,num_nodes,num_nodes))
# remove the 'all others' section
Adj = Adj[1:end-1,1:end-1]
#"in degree"
degreeIn = sum(Adj,dims=1)[:]
Din = spdiagm(0=>degreeIn)

############################
# Analysis integrated time
############################

# linear operator for dynamics
# Adj has arrows going from i to j (rows to colums) 
# so we use transpose ordering
F = Din\Adj'

dt = .01
twindow = 0:dt:1
PsiInt = zeros(size(F))
for t=twindow
    A = exp(F*t)
    Psi = Symmetric(A'*A)
    global PsiInt = PsiInt + dt*Psi
    println(t)
end
PsiInt = PsiInt / (maximum(twindow) - minimum(twindow))
lambda1, EV1 = eigen(PsiInt)
lambda1 = sqrt.(lambda1)
coord1 = lambda1[end]*EV1[:,end]*sign(EV1[1,end]) # we may choose an all positive vec
coord2 = lambda1[end-1]*EV1[:,end-1]
coord3 = lambda1[end-2]*EV1[:,end-2]

##########################
# Ranking 
##########################
rankingInt = sortperm(coord1, rev=true)
rankedNamesInt = NodeNames[rankingInt]

###########################
# Plot Settings
###########################

# select nodes for displaying their name
selection = [1,2,3,4,5,6,7,8,9,21,46,55]
upscale = 1 #8x upscaling in resolution
upscalefont = 1 #8x upscaling in resolution
textsize = 5*upscalefont
msize = 4*upscale
msw= 0.2*upscale
res = 100
fntsm = Plots.font("sans-serif", 8*upscalefont)
fntlg = Plots.font("sans-serif", 9*upscalefont)
fntlg2 = Plots.font("sans-serif", 6*upscalefont)
default(titlefont=fntlg, guidefont=fntlg, legendfont=fntlg2, tickfont=fntsm)
upscalefig = 1/1.8
default(size=(600*upscalefig,400*upscalefig)) #Plot canvas size
default(dpi=res) 

##########################
# Plotting
##########################
Plots.scatter(coord1,coord2,markersize=msize,markerstrokewidth=msw,markerstrokecolor=:white,group=NodeData[1:end-1,5], xscale=:log10, xlims =(0.015,2),xticks=[0.01, 0.1, 1, 10],legend=:topleft)
xlabel!(L"\phi_{i,1}")
ylabel!(L"\phi_{i,2}")
for s in selection
    Plots.annotate!(coord1[s],coord2[s],text(NodeNames[s],textsize,:left))
end
outname = string("PsiIntegrated",case,".pdf")
Plots.savefig(outname)

##########################
# Ranking comparisions
##########################
rankingClauset = 1:size(Adj)[1]
correlationIntegralCase = StatsBase.corspearman(rankingClauset,rankingInt)


#########################
# Print Node Names
#########################
topk = 20
for i in 1:topk
    println(i,". ", rankedNamesInt[i]," (",rankingInt[i],")")
end

########################
# Export results to CSV
########################
topk = 15
open("TopkNodes.csv", "w") do f
    for i in 1:topk
        write(f,join(NodeData[rankingInt[i],:],";"))
        write(f,"\n")
    end
end
open("TopkNodesEdges.csv", "w") do f
    for i in 1:topk
        for j in 1:topk
            weight1 = Adj[rankingInt[i], rankingInt[j]]
            if weight1 != 0
                write(f,string(rankingInt[i],",",rankingInt[j],",",weight1))
                write(f,"\n")
            end
            weight2 = Adj[rankingInt[j], rankingInt[i]]
            if weight2 != 0 && i != j
                write(f,string(rankingInt[j],",",rankingInt[i],",",weight2))
                write(f,"\n")
            end
        end 
    end
end
