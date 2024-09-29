function batchrunToneOdor(listname)

loadpathsToneOdor
loadsubjToneOdor

subjlist = eval(listname);

for s = 1:size(subjlist,1)
   basename = subjlist{s,1};
   hilbampToneOdor(basename);
   zscorerToneOdor(basename,'intra');
   ERPToneOdor(basename) 
end

