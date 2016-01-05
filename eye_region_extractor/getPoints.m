function bs = getPoints(im, model)
bs = detect(im, model, model.thresh);
bs = clipboxes(im, bs);
bs = nms_face(bs,0.3);
end

