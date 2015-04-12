function H = calcH(map1, map2)

    A = zeros(8, 9);
    for i = 1:4
       pt1 = map1(i,:);
       pt2 = map2(i,:);
       A(2*i-1, :) = [-pt1(1) -pt1(2) -1 0 0 0 pt2(1)*pt1(1) pt2(1)*pt1(2) pt2(1)];
       A(2*i, :) = [0 0 0 -pt1(1) -pt1(2) -1 pt2(2)*pt1(1) pt2(2)*pt1(2) pt2(2)];
    end
    [U,S,V]=svd(A);
    X = V(:,end);
    X = X / norm(X);
    H = reshape(X, 3, 3)';
end