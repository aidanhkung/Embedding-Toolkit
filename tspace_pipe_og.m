function [allData, tspacem, megaMat] = tspace_pipe(k, l, graph, num_landmarks, tspace_tsne, numPop)
%data = expression matrix
%k, k in knn
%l, l out of k (l < k)
%graph, number of graphs to calculate
%num_landmarks, number of landmarks
%tspace_tsne, 1 for calculation, 0 if you do not want
%numPop, number of trajectories


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tspace_tsne: 1 = calcualte, 0 = do not calcuate 
gates= cell(2);
parameters.partial_order = [];
parameters.voting_scheme = 'exponential'; % default
parameters.band_sample = 1;
parameters.flock_landmarks = 2;
parameters.verbose = 1;
parameters.deblur = 0;
parameters.snn = 1;
parameters.search_connected_components = 1;
parameters.knn = []; % prebuilt on first run lNN graph
parameters.exclude_points = [];
parameters.gates = gates;
parameters.gate_index = 1;
parameters.gateContext = gates{1, 2};

parameters.metric = 'cosine';
parameters.k = k;
parameters.l = l;
parameters.num_landmarks = num_landmarks;

sessionData = csvread('/Users/kevin/Documents/MATLAB/tSpace_Lab/tSpaceInput.csv', 1);


        % do kmeans
rng(1); % For reproducibility
clusters_trajectories = kmeans(sessionData, numPop, 'MaxIter', 10000); % 'Options', options);

%run PCA on sessionData
rng(1); % For reproducibility

[pScore, pExplained] = pca(sessionData,'NumComponents', 20);


perplex = 50;
theta = 0.3;
rng(1); % For reproducibility
ptSNE = fast_tsne(sessionData, 30, perplex, theta);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part that calls trajectory script.

    %separate cells by kMeans/SOM Population
    indexPops = zeros(numPop, numPop);
    pop = zeros(numPop, 1);
    for i = 1:size(clusters_trajectories,1)
        pop(clusters_trajectories(i)) = pop(clusters_trajectories(i)) + 1;
        indexPops(clusters_trajectories(i),pop(clusters_trajectories(i))) = i;
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Build kNN graph
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 

% Build kNN graph
    tic;
    knn = parfor_spdists_knngraph( sessionData, parameters.k,...
        'distance', parameters.metric,...
        'chunk_size', 1000,... % TODO: parameterize and add opt for ppl without PC toolbox
        'verbose', parameters.verbose );
    if parameters.verbose, fprintf('kNN computed: %gs\n', toc); end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Option 1: Check what does this option do to the data, try out with sythetic data   %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if (parameters.deblur)
        [i, j, s] = find(knn);
        % flock each data point to its knn median
        for ith=1:numel(i)
            data(ith, :) = median(data(j(i==ith), :)); 
        end
        if parameters.verbose, fprintf('re-computing kNN after data median filter\n'); tic; end
    	
        knn = parfor_spdists_knngraph( data, parameters.k, 'distance', parameters.metric, 'chunk_size', 1000, 'SNN', true, 'verbose', true);
        
        if parameters.verbose, fprintf('kNN re-computed after data median filter: %gs\n', toc); end
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Shared Nearest Neighbor
    if (parameters.snn~=0)
        if (parameters.verbose), fprintf('updating using jaccard...\n'); tic; end

        [j, i, s] = find(knn);
        % observational note: i is sorted with k-1 apearences each index
        % use this irreliable observation to make sn faster
        
        nData = size(sessionData,1);
        rem = cell(1, nData);

        tic;
        % for each point 1..n
        parfor ci=1:nData
            
            % grab neighbors            
            from = (ci-1)*parameters.k+1;
            to = ci*parameters.k;
            i_inds = from:to;
            i_neighs = j(i_inds);
            
            % for each neighbor
            for i_ind=i_inds
                i_neigh=j(i_ind);
                
                % grab the neighbor's neighbors
                from = (i_neigh-1)*parameters.k+1;
                to = i_neigh*parameters.k;
                j_neighs = j(from:to);
%                 j_neighs = j(i==i_neigh);
                
                % if the shared neighbors are not many enough
                if sum(ismember(i_neighs, j_neighs)) < parameters.snn
                    
                    % add them to remove list
                    rem{ci} = [rem{ci} i_ind];
                end
            end
        end

        rem = cell2mat(rem);

        % remove relevant indices
        i(rem) = [];
        j(rem) = [];
        s(rem) = [];
        knn = sparse(j, i, s);
    
        if parameters.verbose, fprintf('jaccard computed: %gs\n', toc); end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   knn = spdists_undirected( knn ); % TODO consider removing - outliers? \\ spdists_undirected is a separate function 
   parameters.knn = knn;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
   
  parameters.search_connected_components = true; 
   tspacem = zeros(size(sessionData,1), numPop);
    
   graph_panel = cell(graph,1);
    
    
    for graph_iter = 1:graph
    
	    if (parameters.k~=parameters.l)
	        lknn = spdists_lknn(knn, parameters.l, parameters.verbose );
	    else
	        lknn = knn;
	    end
            
        parfor (i = 1:numPop, feature('numCores'))
            %start event
            s = indexPops(i,1);
            tspacem(:,i) = runpathFinder(sessionData, lknn, parameters, s);
        end
        
        graph_panel{graph_iter} = tspacem;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    tspacem = cat(3, graph_panel{:});
    tspacem = mean(tspacem,3);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %run pca on tspaces
    rng(1); % For reproducibility
    if (size(tspacem,2) >20)
        [tCoeff, tScore, tLatent, tTsquared, tExplained, tMu] = pca(tspacem,'NumComponents', 20);
        tExplain = round(tExplained, 2);
    elseif (size(tspacem,2) <= 20)
        [tCoeff, tScore, tLatent, tTsquared, tExplained, tMu] = pca(tspacem,'NumComponents', 10);
        tExplain = round(tExplained, 2);
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if(tspace_tsne == 1)
    perplex = 50;
    theta = 0.3;
    rng(1); % For reproducibility
    wtSNE = fast_tsne(tspacem, 30, perplex, theta);
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %file with allData (pca on sessionData, ptSNE, kMeans, pca on wanderlusts, wtSNE, wanderlustData)
    index = zeros(size(sessionData,1),1);
    for i = 1:size(sessionData,1)
        index(i,1) = i;
    end
    
    allData = cat(2,index,pExplained, ptSNE, clusters_trajectories, tScore, wtSNE, tspacem);

    %file with megaMat (sessionData, kMeans, pca on wanderlusts)
    megaMat = cat(2,index, clusters_trajectories, tScore);
    csvwrite('/Users/kevin/Documents/MATLAB/tspace_pipe_output.csv', allData)
    csvwrite('/Users/kevin/Documents/MATLAB/tspace_pipe_output2.csv', tExplain)
end

